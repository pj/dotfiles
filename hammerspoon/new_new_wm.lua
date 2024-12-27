require("utils")
local obj = {}
obj.__index = obj
obj.__STACK = "stack"
obj.__EMPTY = "empty"
obj.__PINNED = "pinned"
obj.__ROWS = "rows"
obj.__COLUMNS = "columns"
-- obj.__ROOT = "root"
obj.__FLOAT_ZOOMED = "float_zoomed"

-- Constants for defining screens
obj.__SCREEN_PRIMARY = "primary"

obj.__PERCENTAGE_INCREMENT = 10

-- Metadata
obj.name = "PaulsTilingWM"

-- log a bunch of debugging information
obj._debug = false
obj._logger = nil
obj._hs = nil

function obj.new(loglevel, _logger, _hs, _disable_application_watcher)
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
    self._disable_application_watcher = _disable_application_watcher
    return self
end

function obj:_watcherForApplication(application)
    if self._disable_application_watcher then
        return
    end
    local function onEvent(element, event, watcher, application)
        self._logger.d("Application: %s, Element: %s, Event: %s", application:title(), element, event)
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
        elseif event == self._hs.uielement.watcher.windowResized or event == self._hs.uielement.watcher.windowMoved then
            if self._debounceResize == nil then
                self._debounceResize = {}
            end
            if self._debounceResize[element:id()] == nil then
                self._hs.timer.doAfter(0.4, function()
                    self._logger.d("Starting resize for window: %s, id: %s", element:title(), element:id())
                    self:_reconcile(self._current_layout)
                end)
                self._debounceResize[element:id()] = self._hs.timer.secondsSinceEpoch()
            else
                self._logger.d("Debouncing resize for window: %s, id: %s, time: %s", element:title(), element:id(),
                    self._debounceResize[element:id()])
                local current_time = self._hs.timer.secondsSinceEpoch()
                local time_diff = current_time - self._debounceResize[element:id()]
                if time_diff > 0.6 then
                    self._debounceResize[element:id()] = nil
                end
            end
        end
    end
    self._logger.d("Starting watcher for application: %s", application:name())
    self._windowWatchers[application:name()] = application:newWatcher(
        onEvent,
        application
    )
    self._windowWatchers[application:name()]:start({
        self._hs.uielement.watcher.windowCreated,
        self._hs.uielement.watcher.windowMinimized,
        self._hs.uielement.watcher.windowUnminimized,
        self._hs.uielement.watcher.elementDestroyed,
        self._hs.uielement.watcher.windowResized,
        self._hs.uielement.watcher.windowMoved
    })
end

function obj:_startApplicationWatcher()
    if self._disable_application_watcher then
        return
    end
    self._windowWatchers = {}
    self._applicationWatcher = self._hs.application.watcher.new(
        function(name, event, application)
            if event == self._hs.application.watcher.launched then
                self._logger.i("Application launching: %s", name)
                if self._windowWatchers[name] == nil then
                    self:_watcherForApplication(application)
                end

                for _, window in ipairs(application:visibleWindows()) do
                    self:addWindow(window)
                end
            elseif event == self._hs.application.watcher.terminated then
                self._logger.i("Application deactivated: %s", name)
                if self._windowWatchers[name] ~= nil then
                    self._windowWatchers[name]:stop()
                    self._windowWatchers[name] = nil
                end
            end
        end
    )
    self._applicationWatcher:start({
        self._hs.application.watcher.launching,
        self._hs.application.watcher.terminated
    })
end

function obj:_screenChanged()
    local screens = self._hs.screen.allScreens()
    for _, screen in pairs(screens) do
        self._screen_cache[screen:name()] = screen
    end

end

-- Functions to update the window cache
function obj:start()
    if self._current_layout == nil then
        self._current_layout = {}
    end

    if self._current_layout == nil then
        self._current_layout =
        {
            type = obj.__ROOT,
            child = {
                columns = {
                    {
                        type = obj.__STACK,
                        percentage = 100
                    }
                },
                type = obj.__COLUMNS
            }
        }
    end

    if self._window_cache == nil then
        self._window_cache = {}
    end

    if self._application_cache == nil then
        self._application_cache = {}
    end
    if self._screen_cache == nil then
        self._screen_cache = {}
    end

    local space_filter = self._hs.window.filter.new()

    local windows = space_filter:getWindows()

    if self._windowWatchers == nil then
        self._windowWatchers = {}
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

    self._hs.window.filter.default:subscribe(
        self._hs.window.filter.windowFocused,
        function(window)
            -- Filter out the WMUI window
            if not (window:title() == "WMUI" or window:title() == "Hammerspoon Console") then
                self._logger.i("Focused window changed: %s", window:title())
                self._lastFocusedWindow = window
            else
                self._logger.i("Not changing focused window: WMUI")
            end
        end
    )

    self:_screenChanged()

    self._screenWatcher = self._hs.screen.watcher.new(function()
        self:_screenChanged()
        self:_reconcile(self._current_layout)
    end)

    self._screenWatcher:start()

    self:_reconcile(self._current_layout)
end

function obj:removeWindow(window)
    self._window_cache[window:id()] = nil
    self._application_cache[window:application():name()][window:title()] = nil
    self:_reconcile(self._current_layout)
end

function obj:addWindow(window)
    self._window_cache[window:id()] = window
    if self._application_cache[window:application():name()] == nil then
        self._application_cache[window:application():name()] = { [window:title()] = window }
    else
        self._application_cache[window:application():name()][window:title()] = window
    end
    self:_reconcile(self._current_layout)
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

function obj:setLayout(layout)
    self:_reconcile(layout)
end

function obj:getLayout()
    return self._current_layout
end

function obj:incrementSplit()
    local new_layout = DeepCopy(self._current_layout)
    assert(new_layout ~= nil)

    local sublayout = new_layout
    if new_layout.type == obj.__ROOT then
        sublayout = new_layout.child
    end

    if sublayout.type == obj.__COLUMNS then
        table.insert(sublayout.columns, { type = obj.__EMPTY, percentage = 100 })
    elseif sublayout.type == obj.__ROWS then
        table.insert(sublayout.rows, { type = obj.__EMPTY, percentage = 100 })
    else
        error("Unknown layout type: " .. sublayout.type)
    end

    self:_reconcile(new_layout)
end

function obj:decrementSplit()
    local new_layout = DeepCopy(self._current_layout)
    assert(new_layout ~= nil)

    local sublayout = new_layout
    if new_layout.type == obj.__ROOT then
        sublayout = new_layout.child
    end

    if sublayout.type == obj.__COLUMNS then
        if #sublayout.columns > 1 then
            local last_column = sublayout.columns[#sublayout.columns]
            -- Reposition the stack to the previous column and remove the last column
            if last_column.type == obj.__STACK then
                new_layout.columns[#new_layout.columns - 1] = last_column
            end
            table.remove(sublayout.columns, #sublayout.columns)
        end
    elseif sublayout.type == obj.__ROWS then
        if #sublayout.rows > 1 then
            local last_row = sublayout.rows[#sublayout.rows]
            -- Reposition the stack to the previous column and remove the last column
            if last_row.type == obj.__STACK then
                new_layout.rows[#new_layout.rows - 1] = last_row
            end
            table.remove(sublayout.rows, #sublayout.rows)
        end
    else
        error("Unknown layout type: " .. sublayout.type)
    end

    self:_reconcile(new_layout)
end

function obj:setSplits(number_of_splits)
    local new_layout = DeepCopy(self._current_layout)
    assert(new_layout ~= nil)

    local sublayout = new_layout
    if new_layout.type == obj.__ROOT then
        sublayout = new_layout.child
    end

    local items = nil
    if sublayout.type == obj.__COLUMNS then
        items = sublayout.columns
    elseif sublayout.type == obj.__ROWS then
        items = sublayout.rows
    else
        error("Unknown layout type: " .. sublayout.type)
    end
    assert(items ~= nil)

    -- Decrease the number of splits
    local updatedItems = {}
    if #items > number_of_splits then
        local stack_column = nil
        for x, item in pairs(items) do
            if x <= number_of_splits then
                table.insert(updatedItems, item)
            elseif item.type == obj.__STACK then
                stack_column = item
            end
        end

        if stack_column ~= nil then
            table.remove(updatedItems, #updatedItems)
            table.insert(updatedItems, stack_column)
        end
    else
        for _, item in pairs(items) do
            table.insert(updatedItems, item)
        end
        for x = 1, number_of_splits - #items do
            table.insert(updatedItems, { type = obj.__EMPTY, percentage = 100 })
        end
    end

    if sublayout.type == obj.__COLUMNS then
        sublayout.columns = updatedItems
    elseif sublayout.type == obj.__ROWS then
        sublayout.rows = updatedItems
    else
        error("Unknown layout type: " .. sublayout.type)
    end

    self:_reconcile(new_layout)
end

function obj:_findPinnedAndStack(window, layout, parent, parentIndex)
    -- if layout.type == obj.__ROOT then
    --     local pinned = nil
    --     local pinnedIndex = nil
    --     local stack = nil
    --     local stackIndex = nil
    --     local child_pinned, child_pinned_index, child_stack, child_stack_index = self:_findPinnedAndStack(
    --         window,
    --         layout.child,
    --         layout,
    --         1
    --     )
    --     if child_pinned ~= nil then
    --         pinned = child_pinned
    --         pinnedIndex = child_pinned_index
    --     end
    --     if child_stack ~= nil then
    --         stack = child_stack
    --         stackIndex = child_stack_index
    --     end
    --     return pinned, pinnedIndex, stack, stackIndex
    -- else
    if layout.type == obj.__COLUMNS then
        local pinned = nil
        local pinnedIndex = nil
        local stack = nil
        local stackIndex = nil
        for i, column in pairs(layout.columns) do
            local child_pinned, child_pinned_index, child_stack, child_stack_index = self:_findPinnedAndStack(
                window,
                column,
                layout,
                i
            )
            if child_pinned ~= nil then
                pinned = child_pinned
                pinnedIndex = child_pinned_index
            end
            if child_stack ~= nil then
                stack = child_stack
                stackIndex = child_stack_index
            end
        end
        return pinned, pinnedIndex, stack, stackIndex
    elseif layout.type == obj.__ROWS then
        local pinned = nil
        local pinnedIndex = nil
        local stack = nil
        local stackIndex = nil
        for i, row in pairs(layout.rows) do
            local child_pinned, child_pinned_index, child_stack, child_stack_index = self:_findPinnedAndStack(
                window,
                row,
                layout,
                i
            )
            if child_pinned ~= nil then
                pinned = child_pinned
                pinnedIndex = child_pinned_index
            end
            if child_stack ~= nil then
                stack = child_stack
                stackIndex = child_stack_index
            end
        end
        return pinned, pinnedIndex, stack, stackIndex
    elseif layout.type == obj.__PINNED then
        if self:_windowIsPinned(layout, window) then
            return parent, parentIndex, nil, nil
        end
        return nil, nil, nil, nil
    elseif layout.type == obj.__STACK then
        return nil, nil, parent, parentIndex
    elseif layout.type == obj.__EMPTY then
        return nil, nil, nil, nil
    else
        error("Unknown layout type: " .. layout.type)
    end
end

function obj:_updateFocusedPercentage(setterFunc)
    local new_layout = DeepCopy(self._current_layout)
    local focusedWindow = self._hs.window.focusedWindow()

    -- See if focused window is pinned in the layout
    local pinnedIn, pinnedIndex, stackedIn, stackIndex = self:_findPinnedAndStack(focusedWindow, new_layout, nil, nil)

    if pinnedIn ~= nil then
        if pinnedIn.type == obj.__COLUMNS then
            pinnedIn.columns[pinnedIndex].percentage = setterFunc(pinnedIn.columns[pinnedIndex].percentage)
        elseif pinnedIn.type == obj.__ROWS then
            pinnedIn.rows[pinnedIndex].percentage = setterFunc(pinnedIn.rows[pinnedIndex].percentage)
        else
            error("Unknown layout type: " .. pinnedIn.type)
        end
    elseif stackedIn ~= nil then
        if stackedIn.type == obj.__COLUMNS then
            stackedIn.columns[stackIndex].percentage = setterFunc(stackedIn.columns[stackIndex].percentage)
        elseif stackedIn.type == obj.__ROWS then
            stackedIn.rows[stackIndex].percentage = setterFunc(stackedIn.rows[stackIndex].percentage)
        else
            error("Unknown layout type: " .. stackedIn.type)
        end
    else
        error("No pinned or stack column found")
    end

    self:_reconcile(new_layout)
end

function obj:incrementFocusedPercentage(amount)
    self:_updateFocusedPercentage(function(current) return current + amount end)
end

function obj:decrementFocusedPercentage(amount)
    self:_updateFocusedPercentage(function(current) return current - amount end)
end

function obj:setFocusedColumnPercentage(percentage)
    self:_updateFocusedPercentage(function(current) return percentage end)
end

function obj:moveFocusedTo(destPosition)
    local new_layout = DeepCopy(self._current_layout)
    assert(new_layout ~= nil)
    local focusedWindow = self._hs.window.focusedWindow()

    local pinnedIn, pinnedIndex, stackedIn, stackedIndex = self:_findPinnedAndStack(focusedWindow, new_layout, nil, nil)

    -- Moving pinned window to stack
    if pinnedIn ~= nil and stackedIn ~= nil and stackedIndex == destPosition then
        assert(pinnedIndex ~= nil)
        if pinnedIn.type == obj.__COLUMNS then
            pinnedIn.columns[pinnedIndex] = { type = obj.__EMPTY, percentage = pinnedIn.columns[pinnedIndex].percentage }
        elseif pinnedIn.type == obj.__ROWS then
            pinnedIn.rows[pinnedIndex] = { type = obj.__EMPTY, percentage = pinnedIn.rows[pinnedIndex].percentage }
        else
            error("Unknown layout type: " .. pinnedIn.type)
        end
    elseif pinnedIn ~= nil then
        -- Moving from pinned to a column
        local items = nil
        if pinnedIn.type == obj.__COLUMNS then
            items = pinnedIn.columns
        elseif pinnedIn.type == obj.__ROWS then
            items = pinnedIn.rows
        else
            error("Unknown layout type: " .. pinnedIn.type)
        end

        assert(pinnedIndex ~= nil)
        local sourceColumn = items[pinnedIndex]
        items[pinnedIndex] = { type = obj.__EMPTY, percentage = sourceColumn.percentage }
        if destPosition > #items then
            for _ = 1, destPosition - #items do
                table.insert(items, { type = obj.__EMPTY, percentage = 100 })
            end
        end

        items[destPosition] = sourceColumn
        local destColumn = items[destPosition]
        local newPinned = {
            type = obj.__PINNED,
            percentage = destColumn.percentage,
            title = sourceColumn.title,
            application = sourceColumn.application
        }

        if pinnedIn.type == obj.__COLUMNS then
            pinnedIn.columns[destPosition] = newPinned
        elseif pinnedIn.type == obj.__ROWS then
            pinnedIn.rows[destPosition] = newPinned
        else
            error("Unknown layout type: " .. pinnedIn.type)
        end
    elseif stackedIn ~= nil then
        -- Moving from stack to a column
        if destPosition == stackedIndex then
            return
        end

        local items = nil
        if stackedIn.type == obj.__COLUMNS then
            items = stackedIn.columns
        elseif stackedIn.type == obj.__ROWS then
            items = stackedIn.rows
        else
            error("Unknown layout type: " .. stackedIn.type)
        end

        if destPosition > #items then
            for _ = 1, destPosition - #items do
                table.insert(items, { type = obj.__EMPTY, percentage = 100 })
            end
        end

        local destColumn = items[destPosition]

        local newPinned = {
            type = obj.__PINNED,
            percentage = destColumn.percentage,
            application = focusedWindow:application():name(),
            title = focusedWindow:title()
        }

        if stackedIn.type == obj.__COLUMNS then
            stackedIn.columns[destPosition] = newPinned
        elseif stackedIn.type == obj.__ROWS then
            stackedIn.rows[destPosition] = newPinned
        else
            error("Unknown layout type: " .. stackedIn.type)
        end
    else
        error("No pinned or stack column found")
    end

    self:_reconcile(new_layout)
end

function obj:toggleZoomFocusedWindow()
    local new_layout = DeepCopy(self._current_layout)
    assert(new_layout ~= nil)
    if self._lastFocusedWindow == nil then
        self._logger.w("No last focused window found")
        return
    end
    local focusedWindow = self._lastFocusedWindow
    new_layout.zoomed = new_layout.zoomed or {}
    local new_zoomed = {}
    local found = false
    for _, window in pairs(new_layout.zoomed) do
        if window.application == focusedWindow:application():name() and window.title == focusedWindow:title() then
            found = true
        else
            table.insert(new_zoomed, window)
        end
    end
    if not found then
        table.insert(new_zoomed, {
            type = obj.__PINNED,
            application = focusedWindow:application():name(),
            title = focusedWindow:title()
        })
    end
    new_layout.zoomed = new_zoomed
    self:setLayout(new_layout)
end

function obj:toggleFloatFocusedWindow()
    local new_layout = DeepCopy(self._current_layout)
    assert(new_layout ~= nil)
    if self._lastFocusedWindow == nil then
        self._logger.w("No last focused window found")
        return
    end
    local focusedWindow = self._lastFocusedWindow
    new_layout.floats = new_layout.floats or {}
    local new_floats = {}
    local found = false
    for _, window in pairs(new_layout.floats) do
        if window.application == focusedWindow:application():name() and window.title == focusedWindow:title() then
            found = true
        else
            table.insert(new_floats, window)
        end
    end
    if not found then
        table.insert(new_floats, {
            type = obj.__PINNED,
            application = focusedWindow:application():name(),
            title = focusedWindow:title()
        })
    end
    new_layout.floats = new_floats
    self._logger.d("New layout: %s", self._hs.inspect(new_layout))
    self:setLayout(new_layout)
end

function obj:_positionWindow(screen, window, new_frame)
    self._logger.d("Moving window: %s, to: %s", window:id(), new_frame)
    if window:screen():id() ~= screen:id() then
        self._logger.d("Window is on a different screen")
        window:moveToScreen(screen)
    end
    local current_frame = window:frame()
    self._logger.d("Current frame: %s", current_frame)
    if not current_frame:equals(new_frame) then
        self._logger.d("Current frame is not equal to new frame")
        if current_frame.x ~= new_frame.x or current_frame.y ~= new_frame.y then
            self._logger.d("Moving window: %s, to: %s", window:id(), new_frame.x)
            window:setTopLeft(self._hs.geometry.point(new_frame.x, new_frame.y))
        end
        if current_frame.w ~= new_frame.w or current_frame.h ~= new_frame.h then
            self._logger.d("Moving window: %s, to: %s", window:id(), new_frame.w)
            window:setSize(self._hs.geometry.size(new_frame.w, new_frame.h))
        end
    else
        self._logger.d("Current frame is equal to new frame")
    end
end

function obj:_reconcileDirectional(current_screen, items, bounding_frame, direction, ignored_windows)
    local offset = nil
    local total_span_size = nil
    if direction then
        offset = bounding_frame.x
        total_span_size = bounding_frame.w
    else
        offset = bounding_frame.y
        total_span_size = bounding_frame.h
    end

    local stack_position = nil
    for _, item in pairs(items) do
        local new_frame = nil
        local span_size = total_span_size * (item.percentage / 100)
        if direction then
            new_frame = self._hs.geometry.new(
                offset,
                bounding_frame.y,
                span_size,
                bounding_frame.h
            )
        else
            new_frame = self._hs.geometry.new(
                bounding_frame.x,
                offset,
                bounding_frame.w,
                span_size
            )
        end
        local recursive_stack_position = self:_reconcileRecursive(
            current_screen,
            item,
            new_frame,
            ignored_windows
        )
        if recursive_stack_position ~= nil then
            stack_position = recursive_stack_position
        end
        offset = offset + span_size
    end

    return stack_position
end

function obj:_reconcileRecursive(current_screen, new_layout, current_frame, ignored_windows)
    if new_layout.type == obj.__COLUMNS then
        return self:_reconcileDirectional(current_screen, new_layout.columns, current_frame, true, ignored_windows)
    elseif new_layout.type == obj.__ROWS then
        return self:_reconcileDirectional(current_screen, new_layout.rows, current_frame, false, ignored_windows)
    elseif new_layout.type == obj.__PINNED then
        self._hs.inspect(new_layout.application)
        self._hs.inspect(self._application_cache)
        local application = self._application_cache[new_layout.application]
        if application == nil then
            self._logger.e("Application not found: " .. new_layout.application)
            goto continue
        end

        for _, window in pairs(application) do
            self._logger.d("Window: %s, Title: %s, Column Title: %s", window:id(), window:title(), new_layout.title)
            if ignored_windows[window:id()] == nil and (new_layout.title == nil or window:title() == new_layout.title) then
                ignored_windows[window:id()] = window
                self:_positionWindow(current_screen, window, current_frame)
            end
        end
        ::continue::
        return nil
    elseif new_layout.type == obj.__STACK then
        return current_frame
    elseif new_layout.type == obj.__EMPTY then
        return nil
    else
        error("Unknown layout type: " .. new_layout.type)
    end
end

function obj:_reconcileScreen(screenSetup)
    local current_frame = screenSetup.screen:frame()

    local ignored_windows = {}

    if screenSetup.config.floats ~= nil then
        for _, layout in pairs(screenSetup.config.floats) do
            local application = self._application_cache[layout.application]
            if application == nil then
                self._logger.w("Application not found: " .. layout.application)
                goto continue
            end

            for _, window in pairs(application) do
                if layout.title == nil or window:title() == layout.title then
                    ignored_windows[window:id()] = window
                end
            end

            ::continue::
        end
    end

    if screenSetup.config.zoomed ~= nil then
        for _, layout in pairs(screenSetup.config.zoomed) do
            local application = self._application_cache[layout.application]
            if application == nil then
                self._logger.w("Application not found: " .. layout.application)
                goto continue
            end

            for _, window in pairs(application) do
                if layout.title == nil or window:title() == layout.title then
                    ignored_windows[window:id()] = window
                    self:_positionWindow(screenSetup.screen, window, current_frame)
                end
            end

            ::continue::
        end
    end

    local stack_position = self:_reconcileRecursive(screenSetup.screen, screenSetup.config, current_frame, ignored_windows)

    if stack_position == nil then
        self._logger.e("Stack not found for screen: %s", screenSetup.name)
    end

    for _, stack_window in pairs(self._window_cache) do
        if ignored_windows[stack_window:id()] == nil and stack_window:screen():id() == screenSetup.screen:id() then
            self._logger.d("Stack window: %s, Position: %s", stack_window:id(), stack_position)
            self:_positionWindow(screenSetup.screen, stack_window, stack_position)
        end
    end
end

function obj:_reconcile(new_layout)
    if new_layout.screens ~= nil then
        for _, screenSet in pairs(new_layout.screens) do
            self._logger.d("ScreenSet: %s", screenSet)

            local foundAllScreens = true
            local screensToReconcile = {}
            for screenName, screenConfig in pairs(screenSet) do
                local foundScreen = nil
                if screenName == obj.__SCREEN_PRIMARY then
                    foundScreen = self._hs.screen.primaryScreen()
                else
                    foundScreen = self._screen_cache[screenName]
                end
                if foundScreen == nil then
                    self._logger.w("Screen not found: " .. screenName)
                    foundAllScreens = false
                    break
                else
                    table.insert(screensToReconcile, {
                        name = screenName,
                        screen = foundScreen,
                        config = screenConfig
                    })
                end
            end
            if foundAllScreens then
                local screenNames = {}
                for _, screenSetup in pairs(screensToReconcile) do
                    table.insert(screenNames, screenSetup.name)
                end
                self._logger.i("Reconciling screens: ", self._hs.inspect(screenNames))
                for _, screenSetup in pairs(screensToReconcile) do
                    self:_reconcileScreen(screenSetup)
                end
                break
            end
        end
    end

    self._current_layout = new_layout
end

return obj
