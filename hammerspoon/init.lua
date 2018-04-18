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

function processItems(items, app)
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
  hs.printf('chosen: %s', choice)
  if choice ~= nil then
    currentApp:selectMenuItem(choice.item)
  end
end

function menuSearch()
  currentApp = hs.application.frontmostApplication()
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

-- If you want to set the layouts that are enabled
tiling.set('layouts', {
  'fullscreen', 'side-by-side'
})

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

