local obj = {}
obj.__index = obj

-- Metadata
obj.name = "PaulsSiteBlocker"

-- log a bunch of debugging information
obj._debug = false
obj._logger = nil
obj._hs = nil
obj._io = nil
obj._os = nil

obj._timeLimit = nil
obj._weekendTimeLimit = nil
obj._hostsFilePath = '/etc/hosts'
obj._hostsTemplate = nil
obj._currentTimer = nil
obj._store = nil
obj._blocklistFilename = nil
obj._permanentBlocklistFilename = nil

function obj.new(config, debug, _logger, _hs, _io, _os)
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

    if _io then
        self._io = _io
    else
        self._io = io
    end

    if _os then
        self._os = _os
    else
        self._os = os
    end

    for key, value in pairs(config) do
        local formatted_key = string.format("_%s", key)
        self[formatted_key] = value
    end

    return self
end

function obj:_updateBlockList(block)
    if block then
        local status, err = pcall(function()
            local closerScript = string.format("/usr/bin/osascript %s", self._closeTabScriptFilename)
            local handle = self._io.popen(closerScript)
            if handle == nil then
                error('handle is nil')
            end
            handle:close()
        end)
        self._logger.e(string.format("status: %s err: %s", status, self._hs.inspect(err)))
    end

    local tmpname = self:_generateHostsFile(block)

    local command = string.format(
        "/usr/bin/osascript -e 'do shell script \"sudo cp %s %s\" with administrator privileges'",
        tmpname,
        self._hostsFilePath
    )
    local handle = self._io.popen(command)
    if handle == nil then
        error('handle is nil')
    end
    handle:close()
    self._os.remove(tmpname)
end

function obj:_generateHostsFile(block)
    local blocklist_file = self._io.open(self._blocklistFilename, 'r')
    if blocklist_file == nil then
        error('blocklist_file is nil')
    end

    local permanent_blocklist_file = self._io.open(self._permanentBlocklistFilename, 'r')
    if permanent_blocklist_file == nil then
        error('permanent_blocklist_file is nil')
    end

    local tmpname = self._os.tmpname()
    local dest = self._io.open(tmpname, 'w')
    if dest == nil then
        error('dest is nil')
    end
    local template = self._io.open(self._hostsTemplate, 'r')
    if template == nil then
        error('template is nil')
    end
    for line in template:lines() do
        dest:write(line)
        dest:write('\n')
    end
    if block then
        for item in blocklist_file:lines() do
            dest:write(string.format('0.0.0.0    %s\n', item))
        end
    end
    for item in permanent_blocklist_file:lines() do
        dest:write(string.format('0.0.0.0    %s\n', item))
    end

    template:close()
    blocklist_file:close()
    permanent_blocklist_file:close()
    dest:close()

    return tmpname
end

function obj:resetState()
    self._store.set('currentDay', nil)
    self._store.set('timeSpent', 0)
    self._currentTimer = nil
end

function obj:_runBlockTimer()
    local now = self._os.date('*t')
    local weekday = now.wday > 1 and now.wday < 7
    local timeSpent = self._store.get('timeSpent')
    local actualTimeLimit = nil
    if weekday then
        actualTimeLimit = self._timeLimit
    else
        actualTimeLimit = self._weekendTimeLimit
    end

    local message = self:_checkTime(now)

    if message ~= nil then
        self:_updateBlockList(true)
        self._hs.alert(message)
        self._currentTimer:stop()
        self._currentTimer = nil
        return
    end

    if timeSpent > 55 then
        self._hs.alert(string.format('%d Minutes remaining', actualTimeLimit - timeSpent))
    elseif timeSpent % 5 == 0 then
        self._hs.alert(string.format('%d Minutes remaining', actualTimeLimit - timeSpent))
    end

    timeSpent = timeSpent + 1
    self._store.set('timeSpent', timeSpent)
end

function obj:_checkTime(now)
    local timeSpent = self._store.get('timeSpent')
    local weekday = now.wday > 1 and now.wday < 7
    if (weekday and timeSpent > self._timeLimit) or (not weekday and timeSpent > self._weekendTimeLimit) then
        return 'No more time available today.'
    end

    -- if currentDay.wday > 1 and currentDay.wday < 7 and now.hour >= 8 and now.hour < 17 then
    if now.hour >= 1 and now.hour < 18 then
        return "Go back to work."
    end

    return nil
end

function obj:_hostsFileChanged()
    local tmpname = self:_generateHostsFile(true)

    local generatedContentFile = self._io.open(tmpname, "r")
    if not generatedContentFile then
        return nil
    end

    local generatedContent = generatedContentFile:read("*all")
    generatedContentFile:close()

    local file = io.open(self._hostsFilePath, "r")
    if not file then
        return nil
    end

    local content = file:read("*all")
    file:close()

    if generatedContent ~= content then
        return true
    end

    self._os.remove(tmpname)
    return false
end

function obj:_resetState()
    local now = self._os.date('*t')
    local currentDay = self._store.get('currentDay')
    local timeSpent = self._store.get('timeSpent')
    if currentDay == nil or currentDay.day ~= now.day then
        self._store.set('currentDay', now)
        if self._currentTimer ~= nil then
            self._currentTimer:stop()
        end
        self._currentTimer = nil
        self._store.set('timeSpent', 0)
    end
end

function obj:toggleSiteBlocking()
    self:_resetState()
    local now = self._os.date('*t')

    if self._currentTimer ~= nil then
        self._currentTimer:stop()
        self._currentTimer = nil
        self:_updateBlockList(true)
        self._hs.alert('Starting Blocking...')
    else
        local message = self:_checkTime(now)
        if message ~= nil then
            if self:_hostsFileChanged() then
                self:_updateBlockList(true)
            end
            self._hs.alert(message)
            return
        end

        self:_updateBlockList(false)

        self._currentTimer = self._hs.timer.doEvery(
            60,
            function()
                self:_runBlockTimer()
            end
        )
        self._currentTimer:start()
        self._hs.alert('Enjoy internet time...')
    end
end

function obj:_runTimeOfDayTimer()
    local now = self._os.date('*t')
    -- if currentTimer ~= nil and now.wday > 1 and now.wday < 7 and now.hour >= 8 and now.hour < 17 then
    if self._currentTimer ~= nil and now.hour >= 1 and now.hour < 18 then
        self._currentTimer:stop()
        self._currentTimer = nil
        self:_updateBlockList(true)
        self._hs.alert('Go back to work.')
        return
    end
end

function obj:start()
    self._timeOfDayTimer = self._hs.timer.doEvery(
        15,
        function()
            self:_runTimeOfDayTimer()
        end
    )
end

function obj:getState()
    self:_resetState()
    local now = self._os.date('*t')
    local weekday = now.wday > 1 and now.wday < 7
    local timeSpent = self._store.get('timeSpent')
    local actualTimeLimit = nil
    if weekday then
        actualTimeLimit = self._timeLimit
    else
        actualTimeLimit = self._weekendTimeLimit
    end

    return {
        timeSpent = timeSpent,
        blocked = self._currentTimer == nil,
        timeLimit = actualTimeLimit,
        validTime = not (now.hour >= 1 and now.hour < 18)
    }
end

return obj
--permablockTimer = hs.timer.doEvery(
--  15,
--  function()
--    hs.printf('permablock timer running')
--    local permanent_blocklist_file = io.open('/Users/pauljohnson/.permanent_blocklist', 'r')
--    local hosts_file = io.open(hostsFilePath, 'r')
--    local hosts_data = hosts_file:read('*all')
--    local hosts_changed = false
--    for line in permanent_blocklist_file:lines() do
--      --hs.printf(string.format('checking %s', line))
--      local line_formatted = string.format('0.0.0.0    %s', line)
--      if string.find(hosts_data, line_formatted, 1, true) == nil then
--        hs.printf(string.format('host missing %s', line))
--        hosts_changed = true
--      end
--    end
--    permanent_blocklist_file:close()
--    hosts_file:close()
--    if hosts_changed then
--      if currentTimer == nil then
--        updateBlockList(true)
--      else
--        updateBlockList(false)
--      end
--    end
--  end
--)
--permablockTimer:start()

-- timeOfDayTimer:start()

-- Evening timer based accessing.
-- local blockState = "unknown"
-- eveningTimer = hs.timer.doEvery(
--   60,
--   function()
--     hs.printf(string.format('blockState = %s', blockState))
--     now = os.date('*t')
--     isUnblockTime = now.hour >= 20 and now.hour < 23
--     if blockState ~= "unblocked" and isUnblockTime then
--       updateBlockList(false)
--       blockState = "unblocked"
--       hs.printf('Setting unblocked')
--     elseif blockState ~= "blocking" and not isUnblockTime then
--       updateBlockList(true)
--       blockState = "blocking"
--       hs.printf('Setting blocking')
--     end
--  end
-- )
-- eveningTimer:start()
