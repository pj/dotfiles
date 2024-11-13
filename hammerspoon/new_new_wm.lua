local inspect = require("inspect")
local obj = {}
obj.__STACK = "stack"
obj.__EMPTY = "empty"
obj.__PINNED = "pinned"
obj.__VSPLIT = "vsplit"

obj.__index = obj

-- Metadata
obj.name = "PaulsTilingWM"

-- log a bunch of debugging information
obj._debug = false

obj._initialized = false

-- map of letters to specific layouts

obj._logger = nil

obj._hs = nil

function obj.new(loglevel, _logger, _hs)
    local self = setmetatable({}, obj)
    if _hs then
        obj._hs = _hs
    else
        obj._hs = hs
    end

    local loglevel = loglevel or self._hs.logger.defaultLogLevel
    if _logger then
        self._logger = _logger
    else
        self._logger = self._hs.logger.new('new_wm', loglevel)
        self._logger.d("initializing...")
    end
    return self
end

function obj:_watcherForApplication(application)
    local function onEvent(application, element, event)
        if element:role() ~= "AXWindow" then
            return
        end
        if element:isWindow() and not element:isStandard() then
            return
        end
        self._logger.d("Element: %s, Event: %s", element, event)
        if event == self._hs.uielement.watcher.windowCreated then
            self:addWindow(element)
        elseif event == self._hs.uielement.watcher.windowMinimized then
            self:hideWindow(element)
        elseif event == self._hs.uielement.watcher.windowUnminimized then
            self:showWindow(element)
        elseif event == self._hs.uielement.watcher.elementDestroyed then
            self:removeWindow(element)
        elseif event == self._hs.uielement.watcher.windowResized then
            if self._debounceResize == nil then
                self._debounceResize = {}
            end
            if self._debounceResize[element:id()] == nil then
                self._hs.timer.doAfter(0.4, function(   )
                    self._logger.d("Starting resize for window: %s, id: %s", element:title(), element:id())
                    self:_reconcile(self._current_layout[self._hs.spaces.focusedSpace()])
                end)
                self._debounceResize[element:id()] = self._hs.timer.secondsSinceEpoch()
            else
                self._logger.d("Debouncing resize for window: %s, id: %s, time: %s", element:title(), element:id(), self._debounceResize[element:id()])
                local current_time = self._hs.timer.secondsSinceEpoch()
                local time_diff = current_time - self._debounceResize[element:id()]
                if time_diff > 0.6 then
                    self._debounceResize[element:id()] = nil
                end
            end
        end
    end
    self._logger.d("Starting watcher for application: %s", application:name())
    self._applicationWatchers[application:name()] = application:newWatcher(
        function(element, event) onEvent(application, element, event) end
    )
    self._applicationWatchers[application:name()]:start({
        self._hs.uielement.watcher.windowCreated,
        self._hs.uielement.watcher.windowMinimized,
        self._hs.uielement.watcher.windowUnminimized,
        self._hs.uielement.watcher.elementDestroyed,
        self._hs.uielement.watcher.windowResized
    })
end

function obj:_startApplicationWatcher()
    self._applicationWatchers = {}
    self._applicationWatcher = self._hs.application.watcher.new(
        function(name, event, application)
            if event == self._hs.application.watcher.launched then
                self._logger.i("Application launching: %s", name)
                if self._applicationWatchers[name] == nil then
                    self:_watcherForApplication(application)
                end

                for _, window in ipairs(application:visibleWindows()) do
                    self:addWindow(window)
                end
            end

            if event == self._hs.application.watcher.terminated then
                self._logger.i("Application deactivated: %s", name)
                if self._applicationWatchers[name] ~= nil then
                    self._applicationWatchers[name]:stop()
                    self._applicationWatchers[name] = nil
                end
            end
        end
    )
    self._applicationWatcher:start({self._hs.application.watcher.launching, self._hs.application.watcher.terminated})
end

-- Functions to update the window cache
function obj:start()
    local current_space = self._hs.spaces.focusedSpace()
    if self._current_layout == nil then
        self._current_layout = {}
    end

    if self._current_layout[current_space] == nil then
        self._current_layout[current_space] = { columns = { { type = obj.__STACK, span = 1 } } }
    end

    if self._window_cache == nil then
        self._window_cache = {}
    end

    if self._application_cache == nil then
        self._application_cache = {}
    end

    local space_filter = self._hs.window.filter.new()

    local windows = space_filter:getWindows()

    if self._applicationWatchers == nil then
        self._applicationWatchers = {}
    end

    for _, window in pairs(windows) do
        self._window_cache[window:id()] = window
        local application = window:application()
        if application == nil then
            self._logger.e("Window has no application: %s", window:title())
            goto continue
        end

        if self._application_cache[application:name()] == nil then
            self._application_cache[application:name()] = { [window:title()] = window }
        else
            self._application_cache[application:name()][window:title()] = window
        end

        self:_watcherForApplication(application)
        ::continue::
    end
    self:_startApplicationWatcher()

    self:_reconcile(self._current_layout[current_space])
end

function obj:removeWindow(window)
    local current_space = self._hs.spaces.focusedSpace()
    self._window_cache[window:id()] = nil
    self._application_cache[window:application():name()][window:title()] = nil
    self:_reconcile(self._current_layout[current_space])
end

function obj:addWindow(window)
    local current_space = self._hs.spaces.focusedSpace()
    self._window_cache[window:id()] = window
    if self._application_cache[window:application():name()] == nil then
        self._application_cache[window:application():name()] = { [window:title()] = window }
    else
        self._application_cache[window:application():name()][window:title()] = window
    end
    self:_reconcile(self._current_layout[current_space])
end

function obj:hideWindow(window)
end

function obj:showWindow(window)
end

function obj:_windowIsPinned(column, window)
    if column.application == nil then
        error("column has no application")
    end

    if column.application ~= window:application():name() then
        return false
    end

    if column.title ~= nil and column.title ~= window:title() then
        return false
    end

    return true
end

-- Functions to change the layout

function obj:_copyExistingLayout()
    local current_space = self._hs.spaces.focusedSpace()
    local new_layout = { columns = {} }
    for _, column in pairs(self._current_layout[current_space].columns) do
        table.insert(new_layout.columns, column)
    end
    return new_layout
end

function obj:setLayout(layout)
    self:_reconcile(layout)
end

function obj:getLayout()
    return self._current_layout[self._hs.spaces.focusedSpace()]
end

function obj:incrementSplit()
    local new_layout = self:_copyExistingLayout()
    table.insert(new_layout.columns, { type = obj.__EMPTY, span = 1 })

    self:_reconcile(new_layout)
end

function obj:decrementSplit()
    local new_layout = self:_copyExistingLayout()

    if #new_layout.columns > 1 then
        local last_column = new_layout.columns[#new_layout.columns]
        -- Reposition the stack to the previous column and remove the last column
        if last_column.type == obj.__STACK then
            new_layout.columns[#new_layout.columns - 1] = last_column
        end
        table.remove(new_layout.columns, #new_layout.columns)
    end

    self:_reconcile(new_layout)
end

function obj:setSplits(number_of_splits)
    local new_layout = self:_copyExistingLayout()

    -- Decrease the number of splits
    if #new_layout.columns > number_of_splits then
        local stack_column = nil
        local updatedColumns = {}
        for x, column in pairs(new_layout.columns) do
            if x <= number_of_splits then
                table.insert(updatedColumns, column)
            elseif column.type == obj.__STACK then
                stack_column = column
            end
        end
        new_layout.columns = updatedColumns

        if stack_column ~= nil then
            table.remove(new_layout.columns, #new_layout.columns)
            table.insert(new_layout.columns, stack_column)
        end
    else
        for x = 1, number_of_splits - #new_layout.columns do
            table.insert(new_layout.columns, { type = obj.__EMPTY, span = 1 })
        end
    end

    self:_reconcile(new_layout)
end

function obj:_findPinnedAndStack(layout, window)
    local pinnedAt = nil
    local stackAt = nil
    for x, column in pairs(layout.columns) do
        if column.type == obj.__PINNED and self:_windowIsPinned(column, window) then
            pinnedAt = x
        end

        if column.type == obj.__STACK then
            stackAt = x
        end
    end

    return pinnedAt, stackAt
end

function obj:_updateFocusedSpan(setterFunc)
    local new_layout = self:_copyExistingLayout()
    local focusedWindow = self._hs.window.focusedWindow()

    -- See if focused window is pinned in the layout
    local pinnedAt, stackAt = self:_findPinnedAndStack(new_layout, focusedWindow)

    if pinnedAt ~= nil then
        new_layout.columns[pinnedAt].span = setterFunc(new_layout.columns[pinnedAt].span)
    elseif stackAt ~= nil then
        new_layout.columns[stackAt].span = setterFunc(new_layout.columns[stackAt].span)
    else
        error("No pinned or stack column found")
    end

    self:_reconcile(new_layout)
end

function obj:incrementFocusedSpan()
    self:_updateFocusedSpan(function(current) return current + 1 end)
end

function obj:decrementFocusedSpan()
    self:_updateFocusedSpan(function(current) return current - 1 end)
end

function obj:setFocusedColumnSpan(span)
    self:_updateFocusedSpan(function(current) return span end)
end

function obj:moveLeft()
    local new_layout = self:_copyExistingLayout()
    local focusedWindow = self._hs.window.focusedWindow()

    local pinnedAt, stackAt = self:_findPinnedAndStack(new_layout, focusedWindow)

    local pinnedOrStackAt = pinnedAt or stackAt

    if pinnedOrStackAt ~= nil then
        if pinnedAt == 1 then
            return
        end
        local previousColumn = new_layout.columns[pinnedOrStackAt - 1]
        table.insert(new_layout.columns, pinnedOrStackAt - 1, new_layout[pinnedOrStackAt])
        table.insert(new_layout.columns, pinnedOrStackAt, previousColumn)
    else
        error("No pinned or stack column found")
    end

    self:_reconcile(new_layout)
end

function obj:moveRight()
    local new_layout = self:_copyExistingLayout()
    local focusedWindow = self._hs.window.focusedWindow()

    local pinnedAt, stackAt = self:_findPinnedAndStack(new_layout, focusedWindow)

    local pinnedOrStackAt = pinnedAt or stackAt

    if pinnedOrStackAt ~= nil then
        if pinnedOrStackAt == #new_layout.columns then
            local currentColumn = new_layout.columns[pinnedOrStackAt]
            table.insert(new_layout.columns, currentColumn)
            table.insert(new_layout.columns, pinnedOrStackAt, { type = obj.__EMPTY, span = 1 })
        else
            local nextColumn = new_layout.columns[pinnedOrStackAt + 1]
            table.insert(new_layout.columns, pinnedOrStackAt + 1, new_layout[pinnedOrStackAt])
            table.insert(new_layout.columns, pinnedOrStackAt, nextColumn)
        end
    else
        error("No pinned or stack column found")
    end

    self:_reconcile(new_layout)
end

function obj:moveFocusedTo(destIndex)
    local new_layout = self:_copyExistingLayout()
    local focusedWindow = self._hs.window.focusedWindow()

    local pinnedAt, stackAt = self:_findPinnedAndStack(new_layout, focusedWindow)

    -- Moving pinned window to stack
    if stackAt == destIndex then
        if pinnedAt == nil then
            error("Unable to find window to move to stack")
        end
        new_layout.columns[pinnedAt] = { type = obj.__EMPTY, span = new_layout.columns[pinnedAt].span }
        self:_reconcile(new_layout)
        return
    end

    local pinnedOrStackAt = pinnedAt or stackAt

    if pinnedOrStackAt ~= nil then
        local sourceColumn = new_layout.columns[pinnedOrStackAt]
        table.remove(new_layout.columns, pinnedOrStackAt)
        local destColumn = new_layout.columns[destIndex]
        new_layout.columns[destIndex] = sourceColumn
        table.insert(new_layout.columns, destIndex + 1, destColumn)
    else
        error("No pinned or stack column found")
    end

    self:_reconcile(new_layout)
end

function obj:_positionWindow(window, new_frame)
    self._logger.d("Moving window: %s, to: %s", window:id(), new_frame)
    local current_frame = window:frame()
    self._logger.d("Current frame: %s", current_frame)
    if not current_frame:equals(new_frame) then
        self._logger.d("Current frame is not equal to new frame")
        if current_frame.x ~= new_frame.x then
            self._logger.d("Moving window: %s, to: %s", window:id(), new_frame.x)
            window:setTopLeft(self._hs.geometry.point(new_frame.x, new_frame.y))
        end
        if current_frame.w ~= new_frame.w then
            self._logger.d("Moving window: %s, to: %s", window:id(), new_frame.w)
            window:setSize(self._hs.geometry.size(new_frame.w, new_frame.h))
        end
    else
        self._logger.d("Current frame is equal to new frame")
    end
end

function obj:_reconcile(new_layout)
    local current_space = self._hs.spaces.focusedSpace()
    local current_screen = self._hs.screen.mainScreen()
    local current_frame = current_screen:frame()

    local divisions = 0
    for _, column in ipairs(new_layout.columns) do
        divisions = column.span + divisions
    end

    local window_width = current_frame.w / divisions
    local window_height = current_frame.h

    local left_offset = 0
    local pinned_windows = {}
    local stack_position = nil
    for _, column in pairs(new_layout.columns) do
        if column.type == obj.__PINNED then
            local application = self._application_cache[column.application]
            if application == nil then
                error("Application not found: " .. column.application)
            end

            for _, window in pairs(application) do
                self._logger.d("Window: %s, Title: %s, Column Title: %s", window:id(), window:title(), column.title)
                if column.title == nil or window:title() == column.title then
                    pinned_windows[window:id()] = window
                    local new_frame = self._hs.geometry.new(left_offset, 0, window_width * column.span, window_height)
                    self:_positionWindow(window, new_frame)
                end
            end
        elseif column.type == obj.__STACK then
            stack_position = self._hs.geometry.new(left_offset, 0, window_width * column.span, window_height)
        elseif column.type == obj.__VSPLIT then
            local top_offset = 0
            local total_row_span = 0
            for _, row in pairs(column.rows) do
                total_row_span = total_row_span + row.span
            end
            local row_height = window_height / total_row_span
            for _, row in pairs(column.rows) do
                if row.type == obj.__PINNED then
                    local application = self._application_cache[row.application]
                    if application == nil then
                        error("Application not found: " .. row.application)
                    end

                    for _, window in pairs(application) do
                        self._logger.d("Split Window: %s, Title: %s, Row Title: %s", window:id(), window:title(), row.title)
                        if row.title == nil or window:title() == row.title then
                            pinned_windows[window:id()] = window
                            local new_frame = self._hs.geometry.new(
                                left_offset,
                                top_offset,
                                window_width * column.span,
                                row_height * row.span
                            )
                            self:_positionWindow(window, new_frame)
                        end
                    end
                elseif row.type == obj.__STACK then
                    stack_position = self._hs.geometry.new(left_offset, top_offset, window_width * column.span, row_height * row.span)
                end
                top_offset = top_offset + (row.span * row_height)
            end
        end

        left_offset = left_offset + (column.span * window_width)
    end

    if stack_position == nil then
        error("Stack not found")
    end

    for _, stack_window in pairs(self._window_cache) do
        if pinned_windows[stack_window:id()] == nil then
            local current_frame = stack_window:frame()
            if not current_frame:equals(stack_position) then
                if current_frame.x ~= stack_position.x then
                    stack_window:setTopLeft(self._hs.geometry.point(stack_position.x, stack_position.y))
                end
                if current_frame.w ~= stack_position.w then
                    stack_window:setSize(self._hs.geometry.size(stack_position.w, stack_position.h))
                end
            end
        end
    end

    self._current_layout[current_space] = new_layout
end

return obj