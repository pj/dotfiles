local obj = {}
obj.__index = obj

-- Metadata
obj.name = "WindowWatcher"

-- log a bunch of debugging information
obj._debug = false
obj._logger = nil
obj._hs = nil

obj._applicationWatchers = {}
obj._applicationWatcher = nil

obj._onCreate = nil
obj._onDestroy = nil
obj._onHide = nil
obj._onShow = nil

function obj.new(opts, _logger, _hs)
    local self = setmetatable({}, obj)
    if _hs then
        obj._hs = _hs
    else
        obj._hs = hs
    end

    self._debug = opts.debug or self.debug
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

    self._onCreate = opts.onCreate
    self._onDestroy = opts.onDestroy
    self._onHide = opts.onHide
    self._onShow = opts.onShow

    return self
end

function obj:start()
    local function onEvent(application, element, event)
        if element:role() ~= "AXWindow" then
            return
        end
        self._logger.i("Element: %s, Event: %s", element, event)
        if event == self._hs.uielement.watcher.windowCreated then
            self._onCreate(application, element)
        elseif event == self._hs.uielement.watcher.windowMinimized then
            self._onHide(application, element)
        elseif event == self._hs.uielement.watcher.windowUnminimized then
            self._onShow(application, element)
        elseif event == self._hs.uielement.watcher.elementDestroyed then
            self._onDestroy(application, element)
        end
    end
    for _, application in ipairs(self._hs.application.runningApplications()) do
        self._applicationWatchers[application:name()] = application:newWatcher(
            function(element, event) onEvent(application, element, event) end
        )
        self._applicationWatchers[application:name()]:start({
            self._hs.uielement.watcher.windowCreated,
            self._hs.uielement.watcher.windowMinimized,
            self._hs.uielement.watcher.windowUnminimized,
            self._hs.uielement.watcher.elementDestroyed
        })
    end
    self._applicationWatcher = self._hs.application.watcher.new(
        function(name, event, application)
            if event == self._hs.application.watcher.launched then
                self._logger.i("Application launching: %s", name)
                if self._applicationWatchers[name] == nil then
                    self._applicationWatchers[name] = application:newWatcher(
                        function(element, event) onEvent(application, element, event) end
                    )
                    self._applicationWatchers[name]:start({
                        self._hs.uielement.watcher.windowCreated,
                        self._hs.uielement.watcher.windowMinimized,
                        self._hs.uielement.watcher.windowUnminimized,
                        self._hs.uielement.watcher.elementDestroyed
                    })
                end

                for _, window in ipairs(application:visibleWindows()) do
                    self._onShow(application, window)
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

function obj:stop()
    if self._applicationWatcher then
        self._applicationWatcher:stop()
    else
        self._hs.logger.e("Application watcher not started")
    end
end

return obj