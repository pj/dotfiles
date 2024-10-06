local obj = {}
obj.__index = obj

-- Metadata
obj.name = "PaulsModalCommands"

-- log a bunch of debugging information
obj._debug = false
obj._logger = nil
obj._hs = nil
obj._io = nil
obj._os = nil

function obj.new(config, _logger, _hs, _io, _os)
    local self = setmetatable({}, obj)
    if _hs then
        self._hs = _hs
    else
       self._hs = hs
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

    self._commands = config.commands
    self._current = config.commands
    self._context = {}
    self._executeImmediately = config.executeImmediately
    self._modalKey = config.modalKey
    self._executeKey = config.executeKey
    self._observer = config.observer
    self._completed = false
    self.sequence = {}

    self:_setupModal()

    return self
end

function obj:_setupModal()
    local controlModal = self._hs.hotkey.modal.new("", self._modalKey)

    local mc = self

    function controlModal:entered()
        if mc._observer then
            mc._observer:entered()
        end
    end

    function controlModal:exited()
        if mc._observer then
            mc._observer:exited()
        end
    end

    controlModal:bind("", "escape", function()
        if mc._observer then
            mc._observer:exit()
        end
        controlModal:exit()
    end)

    controlModal:bind("", self._modalKey, function()
        if mc._observer then
            mc._observer:exit()
        end
        controlModal:exit()
    end)
    if not self._executeImmediately then
        controlModal:bind("", self._executeKey, function()
            mc._current:execute(true)
            if mc._observer then
                mc._observer:executed()
            end
            mc._completed = true
        end)
    end

    self._controlModal = controlModal
    self:_bindRecur(self._commands)
end

function obj:_bindRecur(commands)
    for key, command in pairs(commands) do
        self._controlModal:bind("", key, function()
            local completed = self:_step(command.key)
            table.insert(self.sequence, command.key)

            if completed then
                if self._observer then
                    self._observer.executed()
                end
                self._completed = true
            else
                if self._observer then
                    self._observer:pressed(command.key)
                end
            end
        end)
        self:_bindRecur(command.next)
    end
end

function obj:_step(key)
    local nextOp = self._current[key]

    if nextOp == nil then
        return nil
    end

    local context, complete = nextOp:execute(self._context, self._executeImmediately)

    if complete then
        self._observer.executed()
    end

    for key, value in pairs(context) do
        self._context[key] = value
    end

    self._current = nextOp

    return complete
end

return obj