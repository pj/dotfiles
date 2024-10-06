package.path = package.path ..
    ";./hammerspoon/?.lua;/opt/homebrew/share/lua/5.4/?.lua;/opt/homebrew/share/lua/5.4/?/init.lua;/opt/homebrew/lib/lua/5.4/?.lua;/opt/homebrew/lib/lua/5.4/?/init.lua;/usr/local/share/lua/5.4/?.lua;/usr/local/share/lua/5.4/?/init.lua;/usr/local/lib/lua/5.4/?.lua;/usr/local/lib/lua/5.4/?/init.lua"

local lu = require('luaunit')
local site_blocker = require("site_blocker")

function mockTimer()
    local mockTimer = {}
    function mockTimer:start()
    end 
    function mockTimer:stop()
    end 
    return mockTimer
end

function mockHs()
    local mock = {
        logger = { defaultLogLevel = "warning" },
        timer = {
            doEvery = function (_, _) 
                return mockTimer()
            end
        },
        alertedMessages = {}
    }
    function mock.alert(message)
        table.insert(mock.alertedMessages, message)
    end

    function mock.inspect(obj)
        return "inspect contents"
    end

    return mock
end

function mockLogger()
    local testLogger = {}
    testLogger.messages = {}
    testLogger.df = function(format, ...)
        table.insert(testLogger.messages, string.format(format, ...))
    end
    testLogger.d = function(message)
        table.insert(testLogger.messages, message)
    end
    testLogger.e = function(message)
        table.insert(testLogger.messages, message)
    end
    return testLogger
end

function linesIterator(array)
    local index = 0  -- Start before the first element
    local count = #array  -- Get the total number of elements

    -- Return the iterator function
    return function()
        index = index + 1  -- Move to the next element
        if index <= count then
            return array[index]  -- Return the current index and value
        end
    end
end


function mockIO(filedata)
    local mockIO = {
        writtenFiles = {},
        lastCommand = nil
    }

    function mockIO.open(filename, mode)
        if mode == 'w' then
            local mockFile = {
                data = ""
            }
            function mockFile:write(data)
                mockFile.data = mockFile.data .. data
            end

            function mockFile:close()
            end

            mockIO.writtenFiles[filename] = mockFile
            return mockFile
        else
            local mockFile = {}
            function mockFile:lines()
                return linesIterator(filedata[filename])
            end

            function mockFile:close()
            end

            return mockFile
        end
    end

    function mockIO.popen(command)
        mockIO.lastCommand = command
        local mockProc = {}
        function mockProc:close()
        end

        return mockProc
    end

    return mockIO
end

function mockOS(dateTable, tempfilename)
    local mockOS = {}
    function mockOS.date(_)
        return dateTable
    end

    function mockOS.tmpname()
        return tempfilename
    end

    function mockOS.remove()

    end

    return mockOS
end

function newMemStore()
    local store = {}
    function store.set(key, value)
        store[key] = value
    end

    function store.get(key)
        return store[key]
    end

    return store
end

function testToggleDisableBlockValidTime()
    local customDateTable = {
        year = 2024,
        month = 10,
        day = 3,
        hour = 20,
        min = 0,
        sec = 0,
        wday = 3
    }
    local io = mockIO({
        blocklistFilename = { "something.com", "otherthing.com" },
        permanentBlocklistFilename = { "alwaysblock.com" },
        hostsTemplate = {"# commented line", "0.0.0.0    someentry.com"}
    })

    local hs = mockHs()
    local blocker = site_blocker.new(
        {
            store = newMemStore(),
            timeLimit = 60,
            weekendTimeLimit = 60,
            hostsFilePath = "hostsFilePath",
            blocklistFilename = "blocklistFilename",
            permanentBlocklistFilename = "permanentBlocklistFilename",
            hostsTemplate = "hostsTemplate",
        },
        true,
        mockLogger(),
        hs,
        io,
        mockOS(customDateTable, "tmpfile")
    )

    blocker:toggleSiteBlocking()

    lu.assertNotNil(blocker._currentTimer)
    lu.assertEquals(
        io.writtenFiles["tmpfile"].data, 
        "# commented line\n0.0.0.0    someentry.com\n0.0.0.0    alwaysblock.com\n"
    )
    lu.assertEquals(
        io.lastCommand, 
        "/usr/bin/osascript -e 'do shell script \"sudo cp tmpfile hostsFilePath\" with administrator privileges'"
    )
end

function testToggleEnableBlockValidTime()
    local customDateTable = {
        year = 2024,
        month = 10,
        day = 3,
        hour = 20,
        min = 0,
        sec = 0,
        wday = 3
    }
    local io = mockIO({
        blocklistFilename = { "something.com", "otherthing.com" },
        permanentBlocklistFilename = { "alwaysblock.com" },
        hostsTemplate = {"# commented line", "0.0.0.0    someentry.com"}
    })

    local hs = mockHs()
    local store = newMemStore()
    local blocker = site_blocker.new(
        {
            store = store,
            timeLimit = 60,
            weekendTimeLimit = 60,
            hostsFilePath = "hostsFilePath",
            blocklistFilename = "blocklistFilename",
            permanentBlocklistFilename = "permanentBlocklistFilename",
            hostsTemplate = "hostsTemplate",
        },
        true,
        mockLogger(),
        hs,
        io,
        mockOS(customDateTable, "tmpfile")
    )

    blocker._currentTimer = mockTimer()
    store.set('currentDay', customDateTable)
    store.set('timeSpent', 0)

    blocker:toggleSiteBlocking()

    lu.assertNil(blocker._currentTimer)
    lu.assertEquals(
        io.writtenFiles["tmpfile"].data, 
        "# commented line\n0.0.0.0    someentry.com\n0.0.0.0    something.com\n0.0.0.0    otherthing.com\n0.0.0.0    alwaysblock.com\n"
    )
    lu.assertEquals(
        io.lastCommand, 
        "/usr/bin/osascript -e 'do shell script \"sudo cp tmpfile hostsFilePath\" with administrator privileges'"
    )
end

function testToggleDisableBlockInvalidTime()
    local customDateTable = {
        year = 2024,
        month = 10,
        day = 3,
        hour = 12,
        min = 0,
        sec = 0,
        wday = 3
    }
    local io = mockIO({
        blocklistFilename = { "something.com", "otherthing.com" },
        permanentBlocklistFilename = { "alwaysblock.com" },
        hostsTemplate = {"# commented line", "0.0.0.0    someentry.com"}
    })

    local hs = mockHs()
    local blocker = site_blocker.new(
        {
            store = newMemStore(),
            timeLimit = 60,
            weekendTimeLimit = 60,
            hostsFilePath = "hostsFilePath",
            blocklistFilename = "blocklistFilename",
            permanentBlocklistFilename = "permanentBlocklistFilename",
            hostsTemplate = "hostsTemplate",
        },
        true,
        mockLogger(),
        hs,
        io,
        mockOS(customDateTable, "tmpfile")
    )

    blocker:toggleSiteBlocking()

    lu.assertNil(blocker._currentTimer)
    lu.assertEquals(
        io.writtenFiles["tmpfile"].data, 
        "# commented line\n0.0.0.0    someentry.com\n0.0.0.0    something.com\n0.0.0.0    otherthing.com\n0.0.0.0    alwaysblock.com\n"
    )
    lu.assertEquals(
        io.lastCommand, 
        "/usr/bin/osascript -e 'do shell script \"sudo cp tmpfile hostsFilePath\" with administrator privileges'"
    )
    lu.assertEquals(hs.alertedMessages, {"Go back too work."})
end

function testToggleDisableBlockNoTimeLeft()
    local customDateTable = {
        year = 2024,
        month = 10,
        day = 3,
        hour = 12,
        min = 0,
        sec = 0,
        wday = 3
    }
    local io = mockIO({
        blocklistFilename = { "something.com", "otherthing.com" },
        permanentBlocklistFilename = { "alwaysblock.com" },
        hostsTemplate = {"# commented line", "0.0.0.0    someentry.com"}
    })

    local hs = mockHs()
    local store = newMemStore()
    local blocker = site_blocker.new(
        {
            store = store,
            timeLimit = 60,
            weekendTimeLimit = 60,
            hostsFilePath = "hostsFilePath",
            blocklistFilename = "blocklistFilename",
            permanentBlocklistFilename = "permanentBlocklistFilename",
            hostsTemplate = "hostsTemplate",
        },
        true,
        mockLogger(),
        hs,
        io,
        mockOS(customDateTable, "tmpfile")
    )

    store.set('currentDay', customDateTable)
    store.set('timeSpent', 61)
    blocker:toggleSiteBlocking()

    lu.assertNil(blocker._currentTimer)
    lu.assertEquals(
        io.writtenFiles["tmpfile"].data, 
        "# commented line\n0.0.0.0    someentry.com\n0.0.0.0    something.com\n0.0.0.0    otherthing.com\n0.0.0.0    alwaysblock.com\n"
    )
    lu.assertEquals(
        io.lastCommand, 
        "/usr/bin/osascript -e 'do shell script \"sudo cp tmpfile hostsFilePath\" with administrator privileges'"
    )
    lu.assertEquals(hs.alertedMessages, {"No more time available today."})
end

function testToggleBlockTimerAvailableTime()
    local customDateTable = {
        year = 2024,
        month = 10,
        day = 3,
        hour = 20,
        min = 0,
        sec = 0,
        wday = 3
    }
    local io = mockIO({
        blocklistFilename = { "something.com", "otherthing.com" },
        permanentBlocklistFilename = { "alwaysblock.com" },
        hostsTemplate = {"# commented line", "0.0.0.0    someentry.com"}
    })

    local hs = mockHs()
    local store = newMemStore()
    local blocker = site_blocker.new(
        {
            store = store,
            timeLimit = 60,
            weekendTimeLimit = 60,
            hostsFilePath = "hostsFilePath",
            blocklistFilename = "blocklistFilename",
            permanentBlocklistFilename = "permanentBlocklistFilename",
            hostsTemplate = "hostsTemplate",
        },
        true,
        mockLogger(),
        hs,
        io,
        mockOS(customDateTable, "tmpfile")
    )

    store.set('currentDay', customDateTable)
    store.set('timeSpent', 20)
    blocker:toggleSiteBlocking()
    blocker:_runBlockTimer()

    lu.assertNotNil(blocker._currentTimer)
    lu.assertEquals(
        io.writtenFiles["tmpfile"].data, 
        "# commented line\n0.0.0.0    someentry.com\n0.0.0.0    alwaysblock.com\n"
    )
    lu.assertEquals(
        io.lastCommand, 
        "/usr/bin/osascript -e 'do shell script \"sudo cp tmpfile hostsFilePath\" with administrator privileges'"
    )
    lu.assertEquals(hs.alertedMessages, {"Enjoy internet time...", "40 Minutes remaining"})
end

function testToggleBlockTimerOutOfTime()
    local customDateTable = {
        year = 2024,
        month = 10,
        day = 3,
        hour = 20,
        min = 0,
        sec = 0,
        wday = 3
    }
    local io = mockIO({
        blocklistFilename = { "something.com", "otherthing.com" },
        permanentBlocklistFilename = { "alwaysblock.com" },
        hostsTemplate = {"# commented line", "0.0.0.0    someentry.com"}
    })

    local hs = mockHs()
    local store = newMemStore()
    local blocker = site_blocker.new(
        {
            store = store,
            timeLimit = 60,
            weekendTimeLimit = 60,
            hostsFilePath = "hostsFilePath",
            blocklistFilename = "blocklistFilename",
            permanentBlocklistFilename = "permanentBlocklistFilename",
            hostsTemplate = "hostsTemplate",
        },
        true,
        mockLogger(),
        hs,
        io,
        mockOS(customDateTable, "tmpfile")
    )

    store.set('currentDay', customDateTable)
    store.set('timeSpent', 60)
    blocker:toggleSiteBlocking()
    blocker:_runBlockTimer()

    lu.assertNotNil(blocker._currentTimer)
    lu.assertEquals(
        io.writtenFiles["tmpfile"].data, 
        "# commented line\n0.0.0.0    someentry.com\n0.0.0.0    alwaysblock.com\n"
    )
    lu.assertEquals(
        io.lastCommand, 
        "/usr/bin/osascript -e 'do shell script \"sudo cp tmpfile hostsFilePath\" with administrator privileges'"
    )
    lu.assertEquals(hs.alertedMessages, {"Enjoy internet time...", "0 Minutes remaining"})

    blocker:_runBlockTimer()
    lu.assertNil(blocker._currentTimer)
    lu.assertEquals(
        io.writtenFiles["tmpfile"].data, 
        "# commented line\n0.0.0.0    someentry.com\n0.0.0.0    something.com\n0.0.0.0    otherthing.com\n0.0.0.0    alwaysblock.com\n"
    )
    lu.assertEquals(
        io.lastCommand, 
        "/usr/bin/osascript -e 'do shell script \"sudo cp tmpfile hostsFilePath\" with administrator privileges'"
    )
    lu.assertEquals(hs.alertedMessages, {"Enjoy internet time...", "0 Minutes remaining", "No more time available today."})
end

os.exit(lu.LuaUnit.run())
