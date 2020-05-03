#r::Reload

timeLimit := 90
hostsFilePath := "c:\Windows\System32\drivers\etc\hosts"
hostsTemplatePath := "c:\Users\Paul Johnson\Documents\hosts_template"
blockListFilePath := "c:\Users\Paul Johnson\Documents\blocklist"
timeSpent := 0

updateBlockList(block)
{
;   if block then
;     local handle = io.popen('/usr/bin/osascript /Users/pauljohnson/dotfiles/hammerspoon/tabCloser.scpt')
;   end
    if (FileExist("C:\Users\Paul Johnson\Documents\blockfile")) {
        FileDelete, C:\Users\Paul Johnson\Documents\blockfile 
    }
    Loop, read, C:\Users\Paul Johnson\Documents\hosts_template, C:\Users\Paul Johnson\Documents\blockfile
    {
        FileAppend, %A_LoopReadLine%`n
    }
    Loop, read, C:\Users\Paul Johnson\Documents\blocklist, C:\Users\Paul Johnson\Documents\blockfile
    {
        FileAppend, 0.0.0.0    %A_LoopReadLine%`n
    }
;   local permanent_blocklist_file = io.open('/Users/pauljohnson/.permanent_blocklist', 'r')
;   local tmpname = os.tmpname()
;   local dest = io.open(tmpname, 'w')
;   local template = io.open(hostsTemplate, 'r')
;   for line in template:lines() do
;     dest:write(line)
;     dest:write('\n')
;   end
;   if block then
;     for item in blocklist_file:lines() do
;       dest:write(string.format('0.0.0.0    %s\n', item))
;     end
;   end
;   for item in permanent_blocklist_file:lines() do
;     dest:write(string.format('0.0.0.0    %s\n', item))
;   end
;   command = string.format(
;     "/usr/bin/osascript -e 'do shell script \"sudo cp %s %s\" with administrator privileges'",
;     tmpname,
;     hostsFilePath
;   )
;   local handle = io.popen(command)
;   local result = handle:read("*a")
;   hs.printf(result)
;   handle:close()
;   dest:close()
;   os.remove(tmpname)
;   template:close()
    ; blockListFile.Close()
;   permanent_blocklist_file:close()
}

#!t::
updateBlockList(True)

; function resetState()
;   hs.settings.set('currentDay', nil)
;   hs.settings.set('timeSpent', 0)
;   currentTimer = nil
; end

; local currentTimer = nil
; function toggleSiteBlocking()
;   now = os.date('*t')
;   currentDay = hs.settings.get('currentDay')
;   timeSpent = hs.settings.get('timeSpent')
;   if currentDay == nil or currentDay.day ~= now.day then
;     currentDay = now
;     hs.settings.set('currentDay', currentDay)
;     if currentTimer ~= nil then
;       currentTimer:stop()
;     end
;     currentTimer = nil
;     timeSpent = 0
;     hs.settings.set('timeSpent', timeSpent)
;   end

;   if timeSpent > timeLimit then
;     hs.alert('No more time available today.')
;     return
;   end

;   if currentTimer ~= nil then
;     currentTimer:stop()
;     currentTimer = nil
;     -- write block list
;     updateBlockList(true)
;     hs.alert('Starting Blocking...')
;   else
;     -- remove block list
;     updateBlockList(false)

;     currentTimer = hs.timer.doEvery(
;       60,
;       function()
;         timeSpent = hs.settings.get('timeSpent')
;         if timeSpent > timeLimit then
;           updateBlockList(true)
;           hs.alert('Times Up, go do something important.')
;           currentTimer:stop()
;           currentTimer = nil
;           return
;         end

;         if timeSpent < 5 then
;           hs.alert(string.format('%d Minutes remaining', timeLimit - timeSpent))
;         elseif timeSpent < 5 and timeSpent % 2 == 0 then
;           hs.alert(string.format('%d Minutes remaining', timeLimit - timeSpent))
;         elseif timeSpent % 5 == 0 then
;           hs.alert(string.format('%d Minutes remaining', timeLimit - timeSpent))
;         end

;         timeSpent = timeSpent + 1
;         hs.printf(string.format('Ticking... %d', timeSpent))
;         hs.settings.set('timeSpent', timeSpent)
;       end
;     )
;     currentTimer:start()
;     hs.alert('Enjoy internet time...')
;   end
; end

; permablockTimer = hs.timer.doEvery(
;   15,
;   function()
;     hs.printf('permablock timer running')
;     local permanent_blocklist_file = io.open('/Users/pauljohnson/.permanent_blocklist', 'r')
;     local hosts_file = io.open(hostsFilePath, 'r')
;     local hosts_data = hosts_file:read('*all')
;     local hosts_changed = false
;     for line in permanent_blocklist_file:lines() do
;       --hs.printf(string.format('checking %s', line))
;       local line_formatted = string.format('0.0.0.0    %s', line)
;       if string.find(hosts_data, line_formatted, 1, true) == nil then
;         hs.printf(string.format('host missing %s', line))
;         hosts_changed = true
;       end
;     end
;     permanent_blocklist_file:close()
;     hosts_file:close()
;     if hosts_changed then
;       if currentTimer == nil then
;         updateBlockList(true)
;       else
;         updateBlockList(false)
;       end
;     end
;   end
; )
; permablockTimer:start()

return

; -- report time left
; hs.hotkey.bind(mash, "l", function() hs.alert(hs.settings.get('timeSpent')) end)

; -- reset state
; hs.hotkey.bind(mash, "s", function() resetState() end)


