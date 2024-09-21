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

tiling.addLayout('vlc-thirds', function(windows)
  local winCount = #windows

  if winCount == 1 then
    return layouts['fullscreen'](windows)
  end

  for index, win in pairs(windows) do
    local application = win:application()
    local name = application:title()

    --hs.printf('%s', name)
    if name ~= 'VLC' then
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
  'fullscreen', 'side-by-side', 'vlc', 'plex', 'thirds', 'two-thirds', 'plex-thirds', 'vlc-thirds'
})
