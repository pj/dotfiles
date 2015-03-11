package.path = package.path ..
    ";./hammerspoon/?.lua;/opt/homebrew/share/lua/5.4/?.lua;/opt/homebrew/share/lua/5.4/?/init.lua;/opt/homebrew/lib/lua/5.4/?.lua;/opt/homebrew/lib/lua/5.4/?/init.lua;/usr/local/share/lua/5.4/?.lua;/usr/local/share/lua/5.4/?/init.lua;/usr/local/lib/lua/5.4/?.lua;/usr/local/lib/lua/5.4/?/init.lua"

local lu = require('luaunit')
local modal_commands = require("modal_commands")


local mockObserver = {}
mockObserver.__index = mockObserver
function mockObserver.new()
    local self = setmetatable({}, mockObserver)

    return self
end

function mockObserver:entered()
    self._entered = true
end

function mockObserver:pressed(key)
    if self._pressed == nil then
        self._pressed = {}
    end
    table.insert(self._pressed, key)
end

local mockModal = {}
mockModal.__index = mockModal

function mockModal.new(_, modalKey)
    local self = setmetatable({}, mockModal)

    self._modalKey = modalKey
    self._inModal = false
    self._keys = {}

    return self
end

function mockModal:bind(_, key, func)
    self._keys[key] = func
end

function mockModal:press(key)
    if key == self._modalKey and not self._inModal then
        self._inModal = true
        self:entered()
    else
        local keyFunc = self._keys[key]

        if keyFunc == nil then
            error(string.format("unknown key pressed: %s", key))
        end

        keyFunc()
    end
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

function mockHs()
    local hs = {
        hotkey = {
            modal = {
            }

        },
        logger = { defaultLogLevel = "warning" },

    }

    function hs.hotkey.modal.new(_, modalKey)
        local mm = mockModal.new(_, modalKey)
        hs.mockModal = mm
        return mm
    end

    return hs
end

function testExecuteImmediately()
    local observer = mockObserver.new()
    local hs = mockHs()
    local config = {
        debug = true,
        commands = {
            a = {
                next = {
                    c = {
                        next = {}
                    }
                }
            },
            b = {
                next = {}
            }
        },
        executeImmediately = true,
        modalKey = "f15",
        executeKey = "enter",
        observer = observer
    }
    modal_commands.new(
        config,
        mockLogger(),
        hs
    )

    hs.mockModal:press("f15")
    lu.assertTrue(hs.mockModal._inModal)
    lu.assertNotNil(hs.mockModal._keys["a"])
    lu.assertNotNil(hs.mockModal._keys["b"])
    hs.mockModal:press("a")
    lu.assertEquals(observer._pressed, {"a"})
end

function testNotExecuteImmediately()

end

os.exit(lu.LuaUnit.run())
