local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ModalCommander"

obj._debug = false

obj._logger = nil

obj._hs = nil

obj._browser = nil
obj._browserReady = false
obj._browserVisible = false

obj._appWidth = 1000
obj._appHeight = 300

obj._appAddress = "http://127.0.0.1:5173"

obj._periodicUpdateInterval = 60
obj._onPeriodicUpdate = nil
obj._onStart = nil
obj._onMessage = nil
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
        self._logger = self._hs.logger.new('new_wm', loglevel)
        self._logger.d("initializing...")
    end

    self._appWidth = opts.appWidth or self._appWidth
    self._appHeight = opts.appHeight or self._appHeight
    self._appAddress = opts.appAddress or self._appAddress
    self._periodicUpdateInterval = opts.periodicUpdateInterval or self._periodicUpdateInterval
    self._onPeriodicUpdate = opts.onPeriodicUpdate
    self._onStart = opts.onStart
    self._onMessage = opts.onMessage
    self._onShow = opts.onShow
    return self
end

function obj:postMessageToWebview(message)
    if self._browser == nil then
        return
    end
    self._browser:evaluateJavaScript([[
        window.postMessage(]] .. self._hs.json.encode(message) .. [[, ']] .. self._appAddress .. [[');
    ]]

    -- ,
    -- function(result, error)
    --     self._hs.printf("Evaluated JavaScript: %s", self._hs.inspect(result))
    --     self._hs.printf("Evaluated JavaScript error: %s", self._hs.inspect(error))
    -- end
    )
end

function obj:start()
    self._wmuiEventTapper = self._hs.eventtap.new(
        {
            self._hs.eventtap.event.types.keyDown,
            self._hs.eventtap.event.types.keyUp
        },
        function(event)
            local eventType = event:getType()
            if eventType == self._hs.eventtap.event.types.keyDown then
                local keycode = self._hs.keycodes.map[event:getKeyCode()]
                if keycode == 'f16' then
                    if self._browserVisible then
                        self:hideBrowser()
                    else
                        self:focusBrowser()
                    end
                    return true
                end
            end

            return false
        end
    )

    self._wmuiEventTapper:start()
    self._updateStateTimer = self._hs.timer.doEvery(
        self._periodicUpdateInterval,
        function()
            self._hs.printf("Updating browser state")
            if self._browser ~= nil and self._browserVisible then
                if self._onPeriodicUpdate ~= nil then
                    self._onPeriodicUpdate(self)
                end
            end
        end
    )

    self:_createModalCommanderWebview()
    self._updateStateTimer:start()
    if self._onStart ~= nil then
        self._hs.printf("Calling onStart")
        self._onStart(self)
    end
end

function obj:_receiveMessageFromWebview(event)
    if event.body.type == "uiReady" then
        self._browserReady = true
        self:postMessageToWebview({ type = "hammerspoonReady" })
    elseif event.body.type == "exit" then
        if self._browser ~= nil then
            self._browser:hide()
            self._browserVisible = false
            self:postMessageToWebview({ type = "resetState" })
        end
    elseif event.body.type == "log" then
        self._hs.printf("Log: %s", self._hs.inspect(event.body))
    else
        if self._onMessage ~= nil then
            self._onMessage(self, event.body)
        end
    end
end

function obj:_createModalCommanderWebview()
    local usercontent = self._hs.webview.usercontent.new("wmui")
    usercontent:setCallback(function(event) self:_receiveMessageFromWebview(event) end)
    local screenFrame = self._hs.screen.mainScreen():frame()
    local middleX = screenFrame.x + screenFrame.w / 2
    local x = middleX - self._appWidth / 2
    local middleY = screenFrame.y + screenFrame.h / 2
    local y = middleY - self._appHeight / 2
    self._browser = self._hs.webview.new(
        { x = x, y = y, h = self._appHeight, w = self._appWidth },
        { developerExtrasEnabled = true },
        usercontent
    )
    self._browser:url(self._appAddress)
    self._browser:titleVisibility('hidden'):allowTextEntry(true):allowGestures(true)
end

function obj:focusBrowser()
    if self._browser ~= nil and not self._browserVisible then
        self._browser:show()
        self._browser:bringToFront()
        self._browser:hswindow():focus()
        self._browserVisible = true
        if self._onShow ~= nil then
            self._onShow(self)
        end
    end
end

function obj:hideBrowser()
    self._browser:hide()
    self:postMessageToWebview({ type = "resetState" })
    self._browserVisible = false
end

function obj:toggleBrowser()
    if not self._browserVisible then
        self._hs.printf("focusing browser")
        self:focusBrowser()
    else
        self._hs.printf("hiding browser")
        self:hideBrowser()
    end
end

return obj
