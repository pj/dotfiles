-- Mute sound when we sleep - avoids problem where system will start playing
-- sound if headphones are unplugged when sleeping.
function muteOnSleep(event)
    -- if event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.systemDidWake then
    --     for k, device in pairs(hs.audiodevice.allOutputDevices()) do
    --         device:setMuted(true)
    --     end
    -- end
  if eventType == hs.caffeinate.watcher.screensDidUnlock then
      hs.execute("/usr/local/bin/blueutil -p 0 && sleep 1 && /usr/local/bin/blueutil -p 1")
  end
end

local watcher = hs.caffeinate.watcher.new(muteOnSleep)
watcher:start()

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

local tiling = require("hs.tiling")
local mash = {"ctrl", "cmd"}

hs.hotkey.bind(mash, "c", function() tiling.cycleLayout() end)
hs.hotkey.bind(mash, "j", function() tiling.cycle(1) end)
hs.hotkey.bind(mash, "k", function() tiling.cycle(-1) end)
hs.hotkey.bind(mash, "space", function() tiling.promote() end)
hs.hotkey.bind(mash, "f", function() tiling.goToLayout("fullscreen") end)
hs.hotkey.bind(mash, "p", function() tiling.goToLayout("plex") end)
hs.hotkey.bind(mash, "v", function() tiling.goToLayout("vlc") end)
hs.hotkey.bind(mash, "r", function() hs.alert('retiling'); tiling.retile() end)

local layouts = require "hs.tiling.layouts"

tiling.addLayout('side-by-side', function(windows)
  local winCount = #windows

  if winCount == 1 then
    return layouts['fullscreen'](windows)
  end

  for index, win in pairs(windows) do
    local frame = win:screen():frame()

    if index == 1 then
      frame.w = frame.w / 2
    else
      frame.x = frame.x + frame.w / 2
      frame.w = frame.w / 2
    end

    win:setFrame(frame)
  end
end)

tiling.addLayout('vlc', function(windows)
  local winCount = #windows

  if winCount == 1 then
    return layouts['fullscreen'](windows)
  end
  local width

  -- Find and set the size of vlc
  for index, win in pairs(windows) do
    local application = win:application()
    local name = application:title()

    -- hs.printf('%s', name)
    if name == 'VLC' then
      win:setSize(100, 100)
      width = win:size().w
      --hs.printf('vlc width: %d', width)
      local frame = win:screen():frame()
      --hs.printf('window frame x: %d', frame.x)
      --hs.printf('window frame width: %d', frame.w)
      frame.x = frame.x + (frame.w - width)
      frame.w = width
      --hs.printf('window new x: %d', frame.x)
      win:setFrame(frame)
      break
    end
  end

  if width == nil then
    return
  end

  for index, win in pairs(windows) do
    local application = win:application()
    local name = application:title()

    --hs.printf('%s', name)
    if name ~= 'VLC' then
      local frame = win:screen():frame()
      --hs.printf('window frame x: %d', frame.x)
      --hs.printf('window frame width: %d', frame.w)
      frame.w = frame.w - width
      --hs.printf('window new x: %d', frame.x)
      win:setFrame(frame)
    end
  end

end)

tiling.addLayout('plex', function(windows)
  local winCount = #windows

  if winCount == 1 then
    return layouts['fullscreen'](windows)
  end
  local width

  -- Find and set the size of plex
  for index, win in pairs(windows) do
    local application = win:application()
    local name = application:title()

    -- hs.printf('%s', name)
    if name == 'Plex' then
      win:setSize(hs.geometry(nil, nil, 100, 100))
      width = win:size().w
      height = win:size().h
      --hs.printf('vlc width: %d', width)
      local frame = win:screen():frame()
      --hs.printf('window frame x: %d', frame.x)
      --hs.printf('window frame width: %d', frame.w)
      frame.x = frame.x + (frame.w - width)
      frame.w = width
      frame.h = height
      --hs.printf('window new x: %d', frame.x)
      win:setFrame(frame)
      break
    end
  end

  if width == nil then
    return
  end

  for index, win in pairs(windows) do
    local application = win:application()
    local name = application:title()

    --hs.printf('%s', name)
    if name ~= 'Plex' then
      local frame = win:screen():frame()
      --hs.printf('window frame x: %d', frame.x)
      --hs.printf('window frame width: %d', frame.w)
      frame.w = frame.w - width
      --hs.printf('window new x: %d', frame.x)
      win:setFrame(frame)
    end
  end

end)

tiling.addLayout('thirds', function(windows)
  local winCount = #windows

  if winCount == 1 then
    return layouts['fullscreen'](windows)
  end

  for index, win in pairs(windows) do
    local frame = win:screen():frame()

    if index == 1 then
      frame.w = frame.w / 3
    elseif index == 2 then
      frame.x = frame.x + frame.w / 3
      frame.w = frame.w / 3
    else
      frame.x = frame.x + ((frame.w / 3) * 2)
      frame.w = frame.w / 3
    end

    win:setFrame(frame)
  end
end)

tiling.addLayout('two-thirds', function(windows)
  local winCount = #windows

  if winCount == 1 then
    return layouts['fullscreen'](windows)
  end

  for index, win in pairs(windows) do
    local frame = win:screen():frame()

    if index == 1 then
      frame.w = (frame.w / 3) * 2
    else
      frame.x = frame.x + ((frame.w / 3) * 2)
      frame.w = frame.w / 3
    end

    win:setFrame(frame)
  end
end)

tiling.addLayout('plex-thirds', function(windows)
  local winCount = #windows

  if winCount == 1 then
    return layouts['fullscreen'](windows)
  end

  for index, win in pairs(windows) do
    local application = win:application()
    local name = application:title()

    --hs.printf('%s', name)
    if name ~= 'Plex' then
      local frame = win:screen():frame()
      --hs.printf('window frame x: %d', frame.x)
      --hs.printf('window frame width: %d', frame.w)
      frame.x = 0
      frame.w = (frame.w / 3) * 2

      --hs.printf('window new x: %d', frame.x)
      win:setFrame(frame)
    else
      win:setSize(hs.geometry(nil, nil, 100, 100))
      local frame = win:screen():frame()
      --hs.printf('window frame x: %d', frame.x)
      --hs.printf('window frame width: %d', frame.w)
      frame.x = (frame.w / 3) * 2
      frame.w = frame.w / 3
      --hs.printf('window new x: %d', frame.x)
      win:setFrame(frame)

    end
  end

end)

-- If you want to set the layouts that are enabled
tiling.set('layouts', {
  'fullscreen', 'side-by-side', 'vlc', 'plex', 'thirds', 'two-thirds', 'plex-thirds'
})

hs.hotkey.bind({"cmd", "alt"}, "L", function()
  hs.caffeinate.startScreensaver()
end)

local timeLimit = 60
local weekendTimeLimit = 60
local hostsFilePath = '/etc/hosts'
local hostsTemplate = '/Users/pauljohnson/.hosts_template'

function updateBlockList(block)
  if block then
    local status, err = pcall(function () 
      local handle = io.popen('/usr/bin/osascript /Users/pauljohnson/dotfiles/hammerspoon/tabCloser.scpt') 
      handle:close() 
    end)
    hs.printf(string.format("status: %s err: %s", status, hs.inspect(err)))
  end
  local blocklist_file = io.open('/Users/pauljohnson/.blocklist', 'r')
  local permanent_blocklist_file = io.open('/Users/pauljohnson/.permanent_blocklist', 'r')
  local tmpname = os.tmpname()
  local dest = io.open(tmpname, 'w')
  local template = io.open(hostsTemplate, 'r')
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
  command = string.format(
    "/usr/bin/osascript -e 'do shell script \"sudo cp %s %s\" with administrator privileges'",
    tmpname,
    hostsFilePath
  )
  local handle = io.popen(command)
  local result = handle:read("*a")
  hs.printf(result)
  handle:close()
  dest:close()
  os.remove(tmpname)
  template:close()
  blocklist_file:close()
  permanent_blocklist_file:close()
end

function resetState()
  hs.settings.set('currentDay', nil)
  hs.settings.set('timeSpent', 0)
  currentTimer = nil
end

local currentTimer = nil
function toggleSiteBlocking()
  now = os.date('*t')
  currentDay = hs.settings.get('currentDay')
  timeSpent = hs.settings.get('timeSpent')
  if currentDay == nil or currentDay.day ~= now.day then
    currentDay = now
    hs.settings.set('currentDay', currentDay)
    if currentTimer ~= nil then
      currentTimer:stop()
    end
    currentTimer = nil
    timeSpent = 0
    hs.settings.set('timeSpent', timeSpent)
  end

  weekday = now.wday > 1 and now.wday < 7
  if (weekday and timeSpent > timeLimit) or (not weekday and timeSpent > weekendTimeLimit) then
    hs.alert('No more time available today.')
    return
  end

  if currentTimer ~= nil then
    currentTimer:stop()
    currentTimer = nil
    -- write block list
    updateBlockList(true)
    hs.alert('Starting Blocking...')
  else
    hs.printf(hs.inspect(currentDay))
    hs.printf(hs.inspect(now))
    -- Check day of week
    -- if currentDay.wday > 1 and currentDay.wday < 7 and now.hour >= 8 and now.hour < 17 then
    if currentTimer ~= nil and now.hour >= 1 and now.hour < 18 then
      hs.alert('Go back too work.')
      return
    end

    -- remove block list
    updateBlockList(false)

    currentTimer = hs.timer.doEvery(
      60,
      function()
        now = os.date('*t')
        weekday = now.wday > 1 and now.wday < 7
        timeSpent = hs.settings.get('timeSpent')
        actualTimeLimit = nil
        if weekday then
          actualTimeLimit = timeLimit
        else
          actualTimeLimit = weekendTimeLimit
        end

        if timeSpent > actualTimeLimit then
          updateBlockList(true)
          hs.alert('Times Up, go do something important.')
          currentTimer:stop()
          currentTimer = nil
          return
        end

        if actualTimeLimit < 5 then
          hs.alert(string.format('%d Minutes remaining', actualTimeLimit - timeSpent))
        elseif timeSpent < 5 and timeSpent % 2 == 0 then
          hs.alert(string.format('%d Minutes remaining', actualTimeLimit - timeSpent))
        elseif timeSpent % 5 == 0 then
          hs.alert(string.format('%d Minutes remaining', actualTimeLimit - timeSpent))
        end

        timeSpent = timeSpent + 1
        hs.printf(string.format('Ticking... %d', timeSpent))
        hs.settings.set('timeSpent', timeSpent)
      end
    )
    currentTimer:start()
    hs.alert('Enjoy internet time...')
  end
end

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
timeOfDayTimer = hs.timer.doEvery(
 15,
 function()
    hs.printf('time of day')
    now = os.date('*t')
    -- if currentTimer ~= nil and now.wday > 1 and now.wday < 7 and now.hour >= 8 and now.hour < 17 then
    if currentTimer ~= nil and now.hour >= 1 and now.hour < 18 then
      currentTimer:stop()
      currentTimer = nil
      updateBlockList(true)
      hs.alert('Go back to work.')
      return
    end
 end
)
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

-- toggle site blocking
hs.hotkey.bind(mash, "t", function() toggleSiteBlocking() end)
-- report time left
hs.hotkey.bind(mash, "l", function() hs.alert(hs.settings.get('timeSpent')) end)
-- reset state
hs.hotkey.bind(mash, "s", function() resetState() end)
