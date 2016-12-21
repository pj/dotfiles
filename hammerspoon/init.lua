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
