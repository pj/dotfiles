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
