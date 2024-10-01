local obj = {}
obj.__index = obj

-- Metadata
obj.name = "RegularKeyModifier"

-- log a bunch of debugging information
obj._debug = false
obj._logger = nil
obj._hs = nil

obj._pressed = false

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

    return self
end

function obj:start(key, func)
    self._eventTapper = self._hs.eventtap.new({ self._hs.eventtap.event.types.keyDown, self._hs.eventtap.event.types.keyUp },
        function(event)
            local eventType = event:getType()
            if eventType == self._hs.eventtap.event.types.keyDown then
                local keycode = self._hs.keycodes.map[event:getKeyCode()]
                -- self._hs.printf("keycode: %s", keycode)
                if keycode == key then
                    self._pressed = true
                    -- self._hs.printf("control pressed down")
                    return true
                elseif self._pressed then
                    local shouldUnpress = func(event)

                    if shouldUnpress then
                        self._pressed = false
                    end
                end
            elseif eventType == self._hs.eventtap.event.types.keyUp then
                local keycode = self._hs.keycodes.map[event:getKeyCode()]
                if keycode == key then
                    self._pressed = false
                    -- self._hs.printf("control pressed up")
                end
            end

            -- self._hs.printf("ControlPressed: %s", ControlPressed)
        end)

    self._eventTapper:start()
end

return obj
