local obj = {}
obj.__STACK = {}
obj.__EMPTY = {}
obj.__WINDOW = {}
obj.__APPLICATION = {}

obj.__index = obj

-- Metadata
obj.name = "PaulsTilingWM"

-- log a bunch of debugging information
obj._debug = false

obj._initialized = false

obj._current_layout = nil

-- map of letters to specific layouts
obj._layouts = {}

obj._logger = nil

obj._hs = nil

function obj.new(debug, _logger, _hs)
    local self = setmetatable({}, obj)
    if _hs then
        obj._hs = _hs
    else
        obj._hs = hs
    end

    self._debug = debug or self.debug
    local loglevel = self._hs.logger.defaultLogLevel
    if self._debug then
        loglevel = 'debug'
    end
    if _logger then
        self._logger = _logger
    else
        self._logger = self._hs.logger.new('new_wm', loglevel)
        self._logger.d("initializing...")
    end
    return self
end

function obj:_setupCurrentScreen()
    self._logger.d("Adding current screen")
    local current_space = self._hs.spaces.focusedSpace()
    if self._current_layout == nil then
        self._current_layout = {}
        self._current_layout[current_space] = { columns = { { type = obj.__STACK, span = 1, windows = {} } } }
        self:_fullRefreshWindows()
        self._logger.d("added current screen")
    else
        self._logger.d("current screen already exists")
    end
end

function obj:addWindow(window)
    self._logger.d("Adding new window")
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}

    for _, column in pairs(current_layout.columns) do
        if column.type == obj.__STACK then
            local updatedStack = {}
            for k, v in pairs(column.windows) do
                updatedStack[k] = v
            end
            updatedStack[window:id()] = window
            table.insert(new_columns, {
                type = obj.__STACK,
                span = column.span,
                windows = updatedStack
            })
        else
            table.insert(new_columns, column)
        end
    end

    self._current_layout[current_space].columns = new_columns

    self:_rerender()
    self._logger.d("done refreshing windows")
end

function obj:removeWindow(window)
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}

    for _, column in pairs(current_layout.columns) do
        if column.type == obj.__STACK then
            local updatedStack = {}
            for k, v in pairs(column.windows) do
                if v:id() ~= window:id() then
                    updatedStack[k] = v
                end
            end
            table.insert(new_columns, {
                type = obj.__STACK,
                span = column.span,
                windows = updatedStack
            })
        elseif column.window and column.window:id() == window:id() then
            table.insert(new_columns, { type = obj.__EMPTY, span = 1 })
        else
            table.insert(new_columns, column)
        end
    end

    self._current_layout[current_space].columns = new_columns

    self._logger.d("done refreshing windows")
end

function obj:_fullRefreshWindows()
    self._logger.d("full refreshing windows")
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}
    local pinned_windows = {}

    for _, column in ipairs(current_layout.columns) do
        if column.type == obj.__WINDOW then
            if column.window == nil and column.application then
                local application = self._hs.application.find(column.application)
                if application == nil then
                    self._logger.ef("application %s not found", column.application)
                    goto continue
                end

                if application[1] ~= nil then
                    self._logger.ef("first result nil")
                    if #application > 1 then
                        self._logger.ef("more than 1 application found for application name %s", column.application)
                    end
                    application = application[1]
                end

                local appWindows = application:visibleWindows()
                if #appWindows == 0 then
                    self._logger.ef("no windows for %s found", column.application)
                    goto continue
                end

                if #appWindows > 1 then
                    self._logger.ef("more than 1 window found for application name %s", column.application)
                end

                column.window = appWindows[1]
            end
            pinned_windows[column.window:id()] = true
        end
        ::continue::
    end

    for _, column in pairs(current_layout.columns) do
        if column.type == obj.__STACK then
            local space_filter = self._hs.window.filter.new()

            local windows = space_filter:getWindows()
            local updatedStack = {}
            for _, window in pairs(windows) do
                local win_id = window:id()
                if pinned_windows[win_id] == nil then
                    updatedStack[win_id] = window
                end
            end

            table.insert(new_columns, {
                type = obj.__STACK,
                span = column.span,
                windows = updatedStack
            })
        else
            table.insert(new_columns, column)
        end
    end

    self._current_layout[current_space].columns = new_columns

    self:_rerender()
    self._logger.d("done full refreshing windows")
end

function obj:_refreshWindows(existingWindows)
    self._logger.d("refreshing windows")
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}

    local stackAt = nil

    for i, column in ipairs(current_layout.columns) do
        if column.type == obj.__WINDOW then
            if column.window == nil and column.application then
                local application = self._hs.application.find(column.application)
                if application == nil then
                    self._logger.ef("application %s not found", column.application)
                    goto continue
                end

                if application[1] ~= nil then
                    self._logger.ef("first result nil")
                    if #application > 1 then
                        self._logger.ef("more than 1 application found for application name %s", column.application)
                    end
                    application = application[1]
                end

                local appWindows = application:visibleWindows()
                if #appWindows == 0 then
                    self._logger.ef("no windows for %s found", column.application)
                    goto continue
                end

                if #appWindows > 1 then
                    self._logger.ef("more than 1 window found for application name %s", column.application)
                end

                local appWindow = appWindows[1]

                table.insert(new_columns, {
                    type = obj.__WINDOW,
                    span = column.span,
                    window = appWindow
                })
                existingWindows[appWindow:id()] = nil
            else
                table.insert(new_columns, column)
                existingWindows[column.window:id()] = nil
            end
        else
            if column.type == obj.__STACK then
                stackAt = i
            end
            table.insert(new_columns, column)
        end
        ::continue::
    end

    if stackAt == nil then
        error("No stack found")
    end

    new_columns[stackAt] = {
        type = obj.__STACK,
        span = current_layout.columns[stackAt].span,
        windows = existingWindows
    }

    self._current_layout[current_space].columns = new_columns

    self._logger.d("done refreshing windows")
end

-- Rerender the current window
function obj:_rerender()
    self._logger.d("rerendering")
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    local current_screen = self._hs.screen.mainScreen()
    local current_frame = current_screen:frame()

    -- Calculate logical divisions
    local divisions = 0
    for _, column in ipairs(current_layout.columns) do
        divisions = column.span + divisions
    end

    -- list of pinned windows
    local pinned_windows = {}
    for _, column in ipairs(current_layout.columns) do
        if column.type == obj.__WINDOW and column.window then
            pinned_windows[column.window:id()] = true
        end
    end

    local window_width = current_frame.w / divisions
    local window_height = current_frame.h

    local left_offset = 0
    for _, column in pairs(current_layout.columns) do
        local new_frame = self._hs.geometry.new(left_offset, 0, window_width * column.span, window_height)
        if column.type == obj.__WINDOW and not column.window then
            goto continue_rerender
        end
        if column.type == obj.__STACK then
            for _, window in pairs(column.windows) do
                local win_id = window:id()
                if pinned_windows[win_id] == nil then
                    local win_frame = self._hs.geometry.copy(new_frame)
                    local current_frame = window:frame()
                    if not current_frame:equals(win_frame) then
                        if current_frame.x ~= win_frame.x then
                            window:setTopLeft(self._hs.geometry.point(win_frame.x, win_frame.y))
                        end
                        if current_frame.w ~= win_frame.w then
                            window:setSize(self._hs.geometry.size(win_frame.w, win_frame.h))
                        end
                    end
                end
            end
        elseif column.type ~= obj.__EMPTY then
            local window = column.window
            local current_frame = window:frame()
            if not current_frame:equals(new_frame) then
                if current_frame.x ~= new_frame.x then
                    window:setTopLeft(self._hs.geometry.point(new_frame.x, new_frame.y))
                end
                if current_frame.w ~= new_frame.w then
                    window:setSize(self._hs.geometry.size(new_frame.w, new_frame.h))
                end
            end
        end

        ::continue_rerender::
        left_offset = left_offset + (column.span * window_width)
    end

    self._logger.d("done rendering")
end

function obj:incrementSplit()
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    self:setSplits(#current_layout.columns + 1)
end

function obj:decrementSplit()
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    self:setSplits(#current_layout.columns - 1)
end

-- Set the number of splits
function obj:setSplits(number_of_splits)
    self._logger.df("setting splits to %s", number_of_splits)
    self:_setupCurrentScreen()
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}
    if number_of_splits == #current_layout then
        return
    end

    -- Reduce number of splits
    local stackInRange = nil
    local existingStack
    local addToStack = {}
    for i = 1, math.max(number_of_splits, #current_layout.columns) do
        local column = current_layout.columns[i]
        if column == nil then
            table.insert(new_columns, { type = obj.__EMPTY, span = 1 })
        else
            if column.type == obj.__STACK then
                existingStack = column
            end
            if i <= number_of_splits then
                if column.type == obj.__STACK then
                    stackInRange = i
                end
                table.insert(new_columns, column)
            else
                if column.type == obj.__WINDOW then
                    addToStack[column.window:id()] = column.window
                end
            end
        end
    end

    if stackInRange then
        local updatedStack = {}
        for k, v in pairs(current_layout.columns[stackInRange].windows) do
            updatedStack[k] = v
        end
        for k, v in pairs(addToStack) do
            updatedStack[k] = v
        end
        new_columns[stackInRange] = {
            type = obj.__STACK,
            span = current_layout.columns[stackInRange].span,
            windows = updatedStack
        }
    else
        local updatedStack = {}
        for k, v in pairs(existingStack.windows) do
            updatedStack[k] = v
        end
        for k, v in pairs(addToStack) do
            updatedStack[k] = v
        end
        local last = new_columns[#new_columns]
        if last.type == obj.__WINDOW then
            updatedStack[last.window:id()] = last.window
        end
        table.insert(new_columns, 1, { type = obj.__STACK, span = 1, windows = updatedStack })
        table.remove(new_columns, #new_columns)
    end

    self._current_layout[current_space].columns = new_columns

    self:_rerender()
    self._logger.d("done updating splits")
end

function obj:incrementSpan()
    local indexForCurrent = self:_index_for_current_window()

    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]

    self:_setSpanAt(indexForCurrent, current_layout.columns[indexForCurrent].span + 1)
end

function obj:decrementSpan()
    local indexForCurrent = self:_index_for_current_window()

    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]

    self:_setSpanAt(indexForCurrent, current_layout.columns[indexForCurrent].span - 1)
end

function obj:_index_for_current_window()
    local current_window = self._hs.window.focusedWindow()
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    local stackAt = nil
    for i, column in pairs(current_layout.columns) do
        if column.type == obj.__WINDOW and column.window:id() == current_window:id() then
            return i
        elseif column.type == obj.__STACK then
            stackAt = i
        end
    end

    if stackAt == nil then
        error("No stack found")
    end

    return stackAt
end

function obj:_setSpanAt(index, span)
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}
    for i, column in pairs(current_layout.columns) do
        if i == index then
            local copy = {}
            for k, v in pairs(column) do
                copy[k] = v
            end
            copy.span = span
            table.insert(new_columns, copy)
        else
            table.insert(new_columns, column)
        end
    end

    self._current_layout[current_space].columns = new_columns
    self:_rerender()
end

-- Set the number of logical spans for the column
function obj:setColumnSpan(span)
    self._logger.df("setting span of focused to %s", span)
    local indexForCurrent = self:_index_for_current_window()
    self:_setSpanAt(indexForCurrent, span)

    self:_rerender()
    self._logger.d("done setting span")
end

function obj:moveLeft()
    local indexForCurrent = self:_index_for_current_window()

    if indexForCurrent > 1 then
        self:moveFocusedTo(indexForCurrent - 1)
    end
end

function obj:moveRight()
    self:moveFocusedTo(self:_index_for_current_window() + 1)
end

function obj:moveFocusedTo(destIndex)
    self._logger.df("moving focused to %s", destIndex)
    self:_setupCurrentScreen()
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}
    local focusedWindow = self._hs.window.focusedWindow()

    -- if the list of columns is shorter than the position, add empty columns to fill out the list
    local length = math.max(#current_layout.columns, destIndex)

    local sourceIndex = nil
    local stackIndex = nil

    for i = 1, length do
        local column = current_layout.columns[i]
        if column == nil then
            table.insert(new_columns, { type = obj.__EMPTY, span = 1 })
        else
            if column.window ~= nil and column.window:id() == focusedWindow:id() then
                sourceIndex = i
            end
            if column.type == obj.__STACK then
                stackIndex = i
            end
            new_columns[i] = column
        end
    end

    if stackIndex == nil then
        error("No stack found")
    end

    if sourceIndex == destIndex then
        return
    end

    -- moving from stack to dest remove from stack and add to destIndex
    if sourceIndex == nil then
        local existingStack = current_layout.columns[stackIndex]
        local updatedStack = {}
        local currentDest = new_columns[destIndex]
        -- update the destination with the new window
        new_columns[destIndex] = {
            type = obj.__WINDOW,
            name = focusedWindow:title(),
            window = focusedWindow,
            span = currentDest.span
        }

        -- if it's a window add it back to the stack
        if currentDest.window then
            updatedStack[currentDest.window:id()] = currentDest.window
        end

        for k, v in pairs(existingStack.windows) do
            -- remove focused if it's in the stack
            if v:id() ~= focusedWindow:id() then
                updatedStack[k] = v
            end
        end
        new_columns[stackIndex] = { type = obj.__STACK, span = existingStack.span, windows = updatedStack }
    elseif stackIndex == destIndex then
        -- moving from source to stack, remove source and add to stack
        local source = new_columns[sourceIndex]
        new_columns[sourceIndex] = { type = obj.__EMPTY, span = source.span }

        local updatedStack = {}
        local existingStack = new_columns[stackIndex]
        for k, v in pairs(existingStack.windows) do
            updatedStack[k] = v
        end
        updatedStack[focusedWindow:id()] = focusedWindow
        new_columns[stackIndex] = { type = obj.__STACK, span = existingStack.span, windows = updatedStack }
    else
        -- moving from to location to location
        local source = new_columns[sourceIndex]
        new_columns[sourceIndex] = { type = obj.__EMPTY, span = source.span }

        local dest = new_columns[destIndex]
        new_columns[destIndex] = {
            type = obj.__WINDOW,
            name = focusedWindow:title(),
            window = focusedWindow,
            span = dest.span
        }

        if dest.window then
            local updatedStack = {}
            for k, v in pairs(dest.window) do
                updatedStack[k] = v
            end
            updatedStack[dest.window:id()] = dest.window
            new_columns[destIndex] = { type = obj.__STACK, span = dest.span, windows = updatedStack }
        end
    end

    self._current_layout[current_space].columns = new_columns
    self:_rerender()
    self._logger.d("done moving focus")
end

-- Set the specific layout
function obj:setLayout(layout, fullRefresh)
    self._logger.df("setting layout to", layout)
    local current_space = self._hs.spaces.focusedSpace()
    if self._current_layout == nil then
        self._current_layout = {}
    end

    if fullRefresh then
        self._current_layout[current_space] = layout
        self:_fullRefreshWindows()
    else
        local existingWindows = {}
        for _, column in pairs(self._current_layout[current_space].columns) do
            if column.type == obj.__WINDOW then
                table.insert(existingWindows, column.window)
                existingWindows[column.window:id()] = column.window
            elseif column.type == obj.__STACK then
                for _, window in pairs(column.windows) do
                    existingWindows[window:id()] = window
                end
            end
        end
        self._current_layout[current_space] = layout
        self:_refreshWindows(existingWindows)
    end

    self:_rerender()
    self._logger.d("done setting layout")
end

return obj
