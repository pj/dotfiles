local obj = {}
obj.__index = obj

-- Metadata
obj.name = "RegularKeyModifier"

-- log a bunch of debugging information
obj._debug = false
obj._logger = nil
obj._hs = nil

obj._pressed = false
obj._started = nil

function obj.new(debug, onStart, onStop, _logger, _hs)
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

    self._pressed = false

    if onStart then
        self._onStart = onStart
    end
    if onStop then
        self._onStop = onStop
    end
    return self
end

function obj:start(key, func)
    self._eventTapper = self._hs.eventtap.new({ self._hs.eventtap.event.types.keyDown, self._hs.eventtap.event.types.keyUp },
        function(event)
            local eventType = event:getType()
            if eventType == self._hs.eventtap.event.types.keyDown then
                local keycode = self._hs.keycodes.map[event:getKeyCode()]
                if self._pressed then
                    local shouldUnpress = func(event)

                    if shouldUnpress then
                        if self._onStop then
                            self._onStop(event)
                        end
                        self._pressed = false
                    end
                    return true
                elseif not self._pressed and keycode == key then
                    self._pressed = true
                    if not self._started then
                        self._started = true
                        if self._onStart then
                            self._onStart(event)
                        end
                    end
                    return true
                end
            elseif eventType == self._hs.eventtap.event.types.keyUp then
                self._pressed = false
            end
        end)

    self._eventTapper:start()
end

function obj:stop()
    self._eventTapper:stop()
end

return obj
