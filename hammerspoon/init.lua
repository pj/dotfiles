-- CP'd from https://gist.github.com/swo/91ec23d09a3d6da5b684
--function baseMove(x, y, w, h)
--    return function()
--        local win = hs.window.focusedWindow()
--        local f = win:frame()
--        local screen = win:screen()
--        local max = screen:frame()
--
--        f.x = max.w * x
--        f.y = max.h * y
--        f.w = max.w * w
--        f.h = max.h * h
--        win:setFrame(f, 0)
--    end
--end
--hs.hotkey.bind({'alt', 'cmd'}, 'Left', baseMove(0, 0, 0.5, 1))
--hs.hotkey.bind({'alt', 'cmd'}, 'Right', baseMove(0.5, 0, 0.5, 1))
--hs.hotkey.bind({'alt', 'cmd'}, 'Down', baseMove(0, 0.5, 1, 0.5))
--hs.hotkey.bind({'alt', 'cmd'}, 'Up', baseMove(0, 0, 1, 0.5))
-- Mute sound when we sleep - avoids problem where system will start playing
-- sound if headphones are unplugged when sleeping.

function muteOnSleep(event)
    if event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.systemDidWake then
        for k, device in pairs(hs.audiodevice.allOutputDevices()) do
            device:setMuted(true)
        end
        --device = hs.audiodevice.defaultOutputDevice()
        --if device then
        --    hs.alert.show("Muted!")
        --end
    end
end

local watcher = hs.caffeinate.watcher.new(muteOnSleep)
watcher:start()

-- Load miros windows
hyper = {'alt', 'cmd'}
package.path = package.path .. ";./?.lua"
require("position")

function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.vim/hammerspoon/", reloadConfig):start()
hs.alert.show("Config Reloaded!")
