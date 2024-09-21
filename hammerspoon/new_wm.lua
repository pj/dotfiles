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

obj._current_layout = {}

-- map of letters to specific layouts
obj._layouts = {}

obj._logger = nil

-- overridable for tests
function obj:_getFocusedSpace()
    return hs.spaces.focusedSpace()
end

function obj:_getCurrentScreen()
    return hs.screen.mainScreen()
end

function obj:_getApplication(applicationId)
    return hs.application.find(applicationId)
end

function obj:_getFocusedWindow()
    return hs.window.focusedWindow()
end

function obj:_getWindowSpaces(windowId)
    return hs.spaces.windowSpaces(windowId)
end

function obj:_getSpaceWindows()
    local space_filter = hs.window.filter.new()

    return space_filter:getWindows()
end

function obj:init(debug, test)
    self._debug = debug or self.debug
    if self._initialized then
        error("Already initialized")
    end
    local loglevel = hs.logger.defaultLogLevel
    if self._debug then
        loglevel = 'debug'
    end
    self._logger = hs.logger.new('new_wm', loglevel)
    self._logger.d("initializing...")
    
    self._initialized = true
    self._logger.d("initialized")
end

function obj:addCurrentScreen(layout)
    self._logger.d("Adding current screen")
    local current_space = self:_getFocusedSpace()
    self._current_layout = {}
    if layout then
        self._current_layout[current_space] = layout
    else
        self._current_layout[current_space] = {columns = {type = obj.__STACK}}
    end

    self:_rerender()
    self._logger.d("added current screen")
end

-- Rerender the current window
function obj:_rerender()
    self._logger.d("rerendering")
    local current_space = self:_getFocusedSpace()
    local current_layout = self._current_layout[current_space]
    local current_screen = self:_getCurrentScreen()
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
            pinned_windows[column.window.id()] = true
            
        elseif column.type == obj.__APPLICATION then
            local application = self:_getApplication(column.application)

            if #application ~= 1 then
                self._logger.ef("more than 1 application found for application name %s", column.application)
            end

            local appWindows = application:visibleWindows()
            application_windows[application:pid()] = appWindows

            for _, window in pairs(appWindows) do
                pinned_windows[window.id()] = true
            end
        end
    end

    local window_width = current_frame.w / divisions

    local left_offset = 0
    for _, column in pairs(current_layout.columns) do
        local new_frame = hs.geometry:new()
        new_frame.y = 0
        new_frame.x = left_offset
        new_frame.w = window_width
        if column.type == obj.__STACK then
            for _, window in pairs(self:_getSpaceWindows()) do
                local win_id = window.id()
                if pinned_windows[win_id] == nil then
                    local win_frame = hs.geometry:copy(new_frame)
                    window:setFrame(win_frame)
                end
            end
        elseif column.type == obj.__APPLICATION then
            local application = self:_getApplication(column.application)

            if #application ~= 1 then
                self._logger.ef("more than 1 application found for application name %s", column.application)
            end

            local appWindows = application_windows[application:pid()]
            for _, window in pairs(appWindows) do
                local spaces = self:_getWindowSpaces(window.id())
                if spaces[current_space] then
                    window:setFrame(new_frame)
                end
            end
        elseif column.type ~= obj.__EMPTY then
            local window = column.window
            window:setFrame(new_frame)
        end

        left_offset = left_offset + (column.span * window_width)
    end

    self._logger.d("done rendering")
end

-- Make sure that pinned apps are running and replace with __EMPTY if they aren't
function obj:_refresh_pinned_apps()
    self._logger.d("refreshing pinned")

    self._logger.d("done refreshing pinned")
end

-- Set the number of splits
function obj:set_splits(number_of_splits) 
    self._logger.df("setting splits to %s", number_of_splits)
    local current_space = self:_getFocusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}
    if number_of_splits == #current_layout then
        return
    end

    -- Reduce number of splits
    if number_of_splits < #current_layout.columns then
        -- First check if the stack is within range
        local stack_in_range = false
        -- local stack_at = 1
        for i = 1, number_of_splits do
            local column = current_layout.columns[i]
            if column.type == obj.__STACK then
                stack_in_range = true
                -- stack_at = i
            end
        end

        if stack_in_range then
            for _, column in pairs(current_layout.columns) do
                table.insert(new_columns, column)
            end
        else
            -- If stack is not in range, move it to the first position then reposition all the others
            table.insert(new_columns, {type = obj.__STACK, span = 1})
            for _, column in pairs(current_layout.columns) do
                if column.type ~= obj.__STACK then
                    table.insert(new_columns, column)
                end
            end
        end

        -- Truncate the last window
        table.remove(new_columns, #current_layout.columns + 1)
    else
        for _, column in pairs(current_layout.columns) do
            table.insert(new_columns, column)
        end
        table.insert(new_columns, {type = obj.__EMPTY, span = 1})
    end

    self._current_layout[current_space].columns = new_columns

    self:_rerender()
    self._logger.d("done updating splits")
end

-- Set the number of logical spans for the column
function obj:set_column_span(span)
    self._logger.df("setting span of focused to %s", span)
    local current_window = self:_getFocusedWindow()
    local current_space = self:_getFocusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}
    if current_window ~= nil then
        for _, column in pairs(current_layout.columns) do
            if column.window.id() == current_window then
                table.insert(
                    new_columns,
                    {
                        type = obj.__WINDOW,
                        name = column.window_title,
                        window = column.window,
                        span = span
                    }
                )
            else
                table.insert(new_columns, column)
            end
        end
    end

    self._current_layout[current_space].columns = new_columns
    self:_rerender()
    self._logger.d("done setting span")
end

function obj:move_focused_to(position) 
    self._logger.df("moving focused to %s", position)
    local current_space = self:_getFocusedSpace()
    local current_layout = self._current_layout[current_space]
    local new_columns = {}
    local window = self:_getFocusedWindow()
    local application = window:application()
    local window_title = application:title()

    for i, column in ipairs(current_layout.columns) do
        -- If the window is already pinned, replace it with __empty
        if column.window ~= nil and column.window:id() == window:id() then
            table.insert(new_columns, {type = obj.__EMPTY, span = 1})
        end

        if i == position then
            table.insert(
                new_columns,
                {
                    type = obj.__WINDOW,
                    name = window_title,
                    window = window,
                    span = 1
                }
            )
        else
            table.insert(new_columns, column)
        end
    end

    self._current_layout[current_space].columns = new_columns
    self:_rerender()
    self._logger.d("done moving focus")
end

-- Set the specific layout
function obj:set_layout(layout) 
    self._logger.df("setting layout to", layout)
    local current_space = self:_getFocusedSpace()
    self._current_layout[current_space] = layout

    self:_rerender()
    self._logger.d("done setting layout")
end

return obj