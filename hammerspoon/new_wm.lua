local obj={}
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

function obj:_setupCurrentScreen(layout)
    self._logger.d("Adding current screen")
    local current_space = self._hs.spaces.focusedSpace()
    if self._current_layout == nil then
        self._current_layout = {}
        if layout then
            self._current_layout[current_space] = layout
        else
            self._current_layout[current_space] = {columns = {{type = obj.__STACK, span = 1}}}
        end
        self._logger.d("added current screen")
    else
        self._logger.d("current screen already exists")
    end
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
    local application_windows = {}
    for _, column in ipairs(current_layout.columns) do
        if column.type == obj.__WINDOW then
            pinned_windows[column.window:id()] = true
            
        elseif column.type == obj.__APPLICATION then
            local application = self._hs.application.find(column.application)
            if application == nil then
                self._logger.ef("application %s not found", column.application)
                goto continue
            end

            if application[1] ~= nil then
                if #application ~= 1 then
                    self._logger.ef("more than 1 application found for application name %s", column.application)
                    goto continue
                end
                application = application[1]
            end

            local appWindows = application:visibleWindows()
            application_windows[application:pid()] = appWindows

            for _, window in pairs(appWindows) do
                pinned_windows[window:id()] = true
            end
        end
        ::continue::
    end

    local window_width = current_frame.w / divisions
    local window_height = current_frame.h

    local left_offset = 0
    for _, column in pairs(current_layout.columns) do
        local new_frame = self._hs.geometry.new(left_offset, 0, window_width * column.span, window_height)
        if column.type == obj.__STACK then
            local space_filter = self._hs.window.filter.new()

            local windows = space_filter:getWindows()
            for _, window in pairs(windows) do
                local win_id = window:id()
                if pinned_windows[win_id] == nil then
                    local win_frame = self._hs.geometry.copy(new_frame)
                    window:setFrame(win_frame, 0)
                end
            end
        elseif column.type == obj.__APPLICATION then
            local application = self._hs.application.find(column.application)
            if application == nil then
                self._logger.ef("application %s not found", column.application)
                goto continue
            end

            if application[1] ~= nil then
                if #application ~= 1 then
                    self._logger.ef("more than 1 application found for application name %s", column.application)
                    goto continue
                end
                application = application[1]
            end

            local appWindows = application_windows[application:pid()]
            for _, window in pairs(appWindows) do
                local spaces = self._hs.spaces.windowSpaces(window:id())
                if spaces[current_space] then
                    window:setFrame(new_frame, 0)
                end
            end
        elseif column.type ~= obj.__EMPTY then
            local window = column.window
            window:setFrame(new_frame, 0)
        end

        left_offset = left_offset + (column.span * window_width)
        ::continue::
    end

    self._logger.d("done rendering")
end

-- Make sure that pinned apps are running and replace with __EMPTY if they aren't
function obj:_refresh_pinned_apps()
    self._logger.d("refreshing pinned")

    self._logger.d("done refreshing pinned")
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
    if number_of_splits < #current_layout.columns then
        -- First check if the stack is within range
        local stack_in_range = false
        for i = 1, number_of_splits do
            local column = current_layout.columns[i]
            if column.type == obj.__STACK then
                stack_in_range = true
            end
        end

        if stack_in_range then
            for _, column in ipairs(current_layout.columns) do
                table.insert(new_columns, column)
            end
        else
            -- If stack is not in range, move it to the first position then reposition all the others
            table.insert(new_columns, {type = obj.__STACK, span = 1})
            for _, column in ipairs(current_layout.columns) do
                if column.type ~= obj.__STACK then
                    table.insert(new_columns, column)
                end
            end
        end

        -- Truncate to the correct size
        while #new_columns > number_of_splits do
            table.remove(new_columns, #new_columns)
        end
    else
        for _, column in ipairs(current_layout.columns) do
            table.insert(new_columns, column)
        end

        -- Add empty columns to fill out the list
        while #new_columns < number_of_splits do
            table.insert(new_columns, {type = obj.__EMPTY, span = 1})
        end
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

function obj:moveFocusedTo(position) 
    self._logger.df("moving focused to %s", position)
    self:_setupCurrentScreen()
    local current_space = self._hs.spaces.focusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}
    local window = self._hs.window.focusedWindow()

    -- if the list of columns is shorter than the position, add empty columns to fill out the list
    local length = math.max(#current_layout.columns, position)
    
    for i = 1, length do
        local column = current_layout.columns[i]
        if column == nil then
            if i == position then
                table.insert(
                    new_columns,
                    {
                        type = obj.__WINDOW,
                        name = window:title(),
                        window = window,
                        span = 1
                    }
                )
            else
                table.insert(new_columns, {type = obj.__EMPTY, span = 1})
            end
        else
            -- If the window is already pinned, replace it with __empty
            if column.window ~= nil and column.window:id() == window:id() and i ~= position then
                new_columns[i] = {type = obj.__EMPTY, span = 1}
            elseif i == position then
                if column.type ~= obj.__STACK then
                    new_columns[i] = {
                        type = obj.__WINDOW,
                        name = window:title(),
                        window = window,
                        span = 1
                    }
                end
            else
                table.insert(new_columns, column)
            end
        end
    end

    self._current_layout[current_space].columns = new_columns
    self:_rerender()
    self._logger.d("done moving focus")
end

-- Set the specific layout
function obj:setLayout(layout)
    self._logger.df("setting layout to", layout)
    local current_space = self._hs.spaces.focusedSpace()
    if self._current_layout == nil then
        self._current_layout = {}
    end

    self._current_layout[current_space] = layout

    self:_rerender()
    self._logger.d("done setting layout")
end

return obj