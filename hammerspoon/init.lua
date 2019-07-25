-- Mute sound when we sleep - avoids problem where system will start playing
-- sound if headphones are unplugged when sleeping.
function muteOnSleep(event)
    if event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.systemDidWake then
        for k, device in pairs(hs.audiodevice.allOutputDevices()) do
            device:setMuted(true)
        end
    end
end

local watcher = hs.caffeinate.watcher.new(muteOnSleep)
watcher:start()

-- menu item search
local application_menu_items = {}
local currentApp = nil
local currentWindow = nil

function processItems(items, app)
  if items == nil then
    return
  end
  if items['AXTitle'] == nil then
    if items['AXChildren'] ~= nil then
      for k, item in pairs(items['AXChildren']) do
        processItems(item, app)
      end
    else
      for k, item in pairs(items) do
        processItems(item, app)
      end
    end
  else
    if items['AXEnabled'] ~= nil and items['AXEnabled'] and items['AXRole'] == 'AXMenuItem' then
      local pid = app:pid()
      if application_menu_items[pid] == nil then
        application_menu_items[pid] = {items['AXTitle']}
      else
        table.insert(application_menu_items[pid], items['AXTitle'])
      end
    end
    if items['AXChildren'] ~= nil then
      for k, item in pairs(items['AXChildren']) do
        processItems(item, app)
      end
    end
  end
end

function onApplicationActivated(name, event, app)
  if event == hs.application.watcher.activated then
    local pid = app:pid()
    if application_menu_items[pid] == nil then
      app:getMenuItems(function (items) processItems(items, app) end)
    end
  end
end

local application_watcher = hs.application.watcher.new(onApplicationActivated)
application_watcher:start()

local chooser = nil
function menuComplete(choice)
  hs.printf('chosen: %s', hs.inspect.inspect(choice))
  if choice ~= nil then
    hs.printf('current app: %s', currentApp)
    hs.printf('current window: %s', currentWindow)
    currentWindow:focus()
    currentApp:selectMenuItem(choice.item)
  end
end

function menuSearch()
  currentApp = hs.application.frontmostApplication()
  currentWindow = hs.window.frontmostWindow()
  chooser:query('')
  chooser:show()
end

chooser = hs.chooser.new(menuComplete)

function queryChanged()
  local query = chooser:query():lower()
  if query:len() < 2 then
    return
  end
  hs.printf('query: %s', chooser:query())
  if currentApp == nil then
    return
  end

  local pid = currentApp:pid()
  --hs.printf('%d', pid)
  --for k, item in pairs(application_menu_items) do
  --  hs.printf('%s', type(k))
  --end
  --hs.printf('%s', hs.inspect.inspect(application_menu_items))
  --hs.printf('%s', hs.inspect.inspect(application_menu_items[pid]))

  if application_menu_items[pid] ~= nil then
    --hs.printf('has items')
    local newChoices = {}
    local items = application_menu_items[pid]
    --hs.printf('%s', hs.inspect.inspect(items))
    for i, item in ipairs(items) do
      --hs.printf('item %s', item)
      if item:lower():match(query) then
        --hs.printf('qwer')
        table.insert(newChoices, {text = item, item = item})
        --hs.printf('lllll')
      end
    end
    --hs.printf('asdf')
    hs.printf('%s', hs.inspect.inspect(newChoices))
    chooser:choices(newChoices)
    --hs.printf('here')
  else
    currentApp:getMenuItems(function (items) processItems(items, currentApp) end)
  end
end

chooser:queryChangedCallback(queryChanged)

hs.hotkey.bind(
  {'alt', 'ctrl', 'cmd'},
  'space',
  nil,
  menuSearch
)

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Load miros windows
--hyper = {'alt', 'cmd'}
--package.path = package.path .. ";./?.lua"
--require("position")

local tiling = require("hs.tiling")
local mash = {"ctrl", "cmd"}

hs.hotkey.bind(mash, "c", function() tiling.cycleLayout() end)
hs.hotkey.bind(mash, "j", function() tiling.cycle(1) end)
hs.hotkey.bind(mash, "k", function() tiling.cycle(-1) end)
hs.hotkey.bind(mash, "space", function() tiling.promote() end)
hs.hotkey.bind(mash, "f", function() tiling.goToLayout("fullscreen") end)
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

-- If you want to set the layouts that are enabled
tiling.set('layouts', {
  'fullscreen', 'side-by-side', 'vlc', 'thirds', 'two-thirds'
})

hs.hotkey.bind({"cmd", "alt"}, "L", function()
  hs.caffeinate.startScreensaver()
end)

--local modal = hs.hotkey.modal.new({}, "F17")
--
--local pressedF18 = function()
--  -- hs.alert.show('enter modal')
--  modal:enter()
--end
--
--local releasedF18 = function()
--  -- hs.alert.show('exit modal')
--  modal:exit()
--end
--
--modal:bind({}, "f", 'caps-h', function() tiling.goToLayout("fullscreen") end)
--
--local f18 = hs.hotkey.bind({}, 'F18', pressedF18, releasedF18)

local timeLimit = 90
local hostsFilePath = '/etc/hosts'
local hostsTemplate = '/Users/pauljohnson/.hosts_template'

function updateBlockList(block)
  if block then
    local handle = io.popen('/usr/bin/osascript /Users/pauljohnson/.vim/hammerspoon/tabCloser.scpt')
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

  if timeSpent > timeLimit then
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
    -- remove block list
    updateBlockList(false)

    currentTimer = hs.timer.doEvery(
      60,
      function()
        timeSpent = hs.settings.get('timeSpent')
        if timeSpent > timeLimit then
          updateBlockList(true)
          hs.alert('Times Up, go do something important.')
          currentTimer:stop()
          currentTimer = nil
          return
        end

        if timeSpent < 5 then
          hs.alert(string.format('%d Minutes remaining', timeLimit - timeSpent))
        elseif timeSpent < 5 and timeSpent % 2 == 0 then
          hs.alert(string.format('%d Minutes remaining', timeLimit - timeSpent))
        elseif timeSpent % 5 == 0 then
          hs.alert(string.format('%d Minutes remaining', timeLimit - timeSpent))
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

permablockTimer = hs.timer.doEvery(
  15,
  function()
    hs.printf('permablock timer running')
    local permanent_blocklist_file = io.open('/Users/pauljohnson/.permanent_blocklist', 'r')
    local hosts_file = io.open(hostsFilePath, 'r')
    local hosts_data = hosts_file:read('*all')
    local hosts_changed = false
    for line in permanent_blocklist_file:lines() do
      --hs.printf(string.format('checking %s', line))
      local line_formatted = string.format('0.0.0.0    %s', line)
      if string.find(hosts_data, line_formatted, 1, true) == nil then
        hs.printf(string.format('host missing %s', line))
        hosts_changed = true
      end
    end
    permanent_blocklist_file:close()
    hosts_file:close()
    if hosts_changed then
      if currentTimer == nil then
        updateBlockList(true)
      else
        updateBlockList(false)
      end
    end
  end
)
permablockTimer:start()

-- toggle site blocking
hs.hotkey.bind(mash, "t", function() toggleSiteBlocking() end)
-- report time left
hs.hotkey.bind(mash, "l", function() hs.alert(hs.settings.get('timeSpent')) end)
-- reset state
hs.hotkey.bind(mash, "s", function() resetState() end)
