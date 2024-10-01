local obj = {}
obj.__index = obj

-- Metadata
obj.name = "WindowManagerWatcher"

-- log a bunch of debugging information
obj._debug = false
obj._logger = nil
obj._hs = nil

obj._wm = nil
obj._applicationWatchers = {}
obj._applicationWatcher = nil

function obj.new(wm, debug, _logger, _hs)
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
        self._logger = self._hs.logger.new('site_blocker', loglevel)
        self._logger.d("initializing...")
    end

    self._wm = wm

    return self
end

function obj:start()
    self._applicationWatcher = self._hs.application.watcher.new(function(name, event, application)
        if event == self._hs.application.watcher.launched then
            self._logger.i("Application launching: %s", name)
            if self._applicationWatchers[name] == nil then
                self._applicationWatchers[name] = application:newWatcher(function(element, event)
                    if element:role() ~= "AXWindow" then
                        return
                    end
                    self._logger.i("Element: %s, Event: %s", element, event)
                    if event == self._hs.uielement.watcher.windowCreated then
                        WM:addWindow(element)
                    elseif event == self._hs.uielement.watcher.windowMinimized then
                        WM:removeWindow(element)
                    elseif event == self._hs.uielement.watcher.windowUnminimized then
                        WM:addWindow(element)
                    elseif event == self._hs.uielement.watcher.elementDestroyed then
                        WM:removeWindow(element)
                    end
                end)
                self._applicationWatchers[name]:start({
                    self._hs.uielement.watcher.windowCreated,
                    self._hs.uielement.watcher.windowMinimized,
                    self._hs.uielement.watcher.windowUnminimized,
                    self._hs.uielement.watcher.elementDestroyed
                })
            end

            for _, window in ipairs(application:visibleWindows()) do
                WM:addWindow(window)
            end
        end

        if event == self._hs.application.watcher.terminated then
            self._logger.i("Application deactivated: %s", name)
            if self._applicationWatchers[name] ~= nil then
                self._applicationWatchers[name]:stop()
                self._applicationWatchers[name] = nil
            end
        end
    end)
    self._applicationWatcher:start({self._hs.application.watcher.launching, self._hs.application.watcher.terminated})
end

function obj:stop()
    if self._applicationWatcher then
        self._applicationWatcher:stop()
    else
        self._hs.logger.e("Application watcher not started")
    end
end

return obj