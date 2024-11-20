package.path = package.path ..
    ";./hammerspoon/?.lua;/opt/homebrew/share/lua/5.4/?.lua;/opt/homebrew/share/lua/5.4/?/init.lua;/opt/homebrew/lib/lua/5.4/?.lua;/opt/homebrew/lib/lua/5.4/?/init.lua;/usr/local/share/lua/5.4/?.lua;/usr/local/share/lua/5.4/?/init.lua;/usr/local/lib/lua/5.4/?.lua;/usr/local/lib/lua/5.4/?/init.lua"

local lu = require('luaunit')
local new_wm = require("new_new_wm")

local mockGeometry = {}
mockGeometry.__index = mockGeometry
function mockGeometry.new(x, y, w, h)
    local self = setmetatable({}, mockGeometry)

    self.x = x
    self.y = y
    self.w = w
    self.h = h

    return self
end

function mockGeometry:equals(t2)
    return self.x == t2.x and self.y == t2.y and self.w == t2.w and self.h == t2.h
end

function mockGeometry.copy(frame)
    return mockGeometry.new(frame.x, frame.y, frame.w, frame.h)
end

function mockGeometry.point(x, y)
    return mockGeometry.new(x, y, nil, nil)
end

function mockGeometry.size(w, h)
    return mockGeometry.new(nil, nil, w, h)
end

function mockWindowModule(windows)
    local mockWindowModule = {}
    function mockWindowModule.focusedWindow()
        return mockWindowModule._focusedWindow
    end

    mockWindowModule.filter = {
        new = function()
            return {
                getWindows = function()
                    return windows
                end
            }
        end,
        default = {
            subscribe = function(event, callback)
            end
        }
    }

    return mockWindowModule
end

function mockHs(windows)
    return {
        logger = { defaultLogLevel = "warning" },
        spaces = {
            focusedSpace = function()
                return 1
            end
        },
        screen = {
            mainScreen = function()
                return {
                    frame = function()
                        return mockGeometry.new(0, 0, 120, 100)
                    end
                }
            end
        },
        geometry = mockGeometry,
        window = mockWindowModule(windows),
        application = {
            find = function(name)
                return nil
            end
        }
    }
end

function mockApplication(name)
    local mockApplication = {}

    function mockApplication:name()
        return name
    end

    return mockApplication
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
    testLogger.w = function(message)
        table.insert(testLogger.messages, message)
    end
    testLogger.ef = function(format, ...)
        table.insert(testLogger.messages, string.format(format, ...))
    end
    return testLogger
end

function mockWindow(id, name, applicationName)
    local mockWindow = {
        _frame = mockGeometry.new(999, 999, 999, 999)
    }
    function mockWindow:id()
        return id
    end

    function mockWindow:setFrame(frame)
        self._frame = frame
    end

    function mockWindow:setTopLeft(frame)
        self._frame = mockGeometry.new(frame.x, frame.y, self._frame.w, self._frame.h)
    end

    function mockWindow:setSize(frame)
        self._frame = mockGeometry.new(self._frame.x, self._frame.y, frame.w, frame.h)
    end

    function mockWindow:title()
        return name
    end

    function mockWindow:frame()
        return self._frame
    end

    function mockWindow:application()
        return mockApplication(applicationName)
    end

    return mockWindow
end

function testSetLayout()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }), true)
    wm:start()

    wm:setLayout({
        type = new_wm.__ROOT,

        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = "Foo"
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, mockGeometry.new(60, 0, 60, 100))
    lu.assertEquals(barWindow._frame, mockGeometry.new(0, 0, 60, 100))
    lu.assertEquals(bazWindow._frame, mockGeometry.new(0, 0, 60, 100))
end

function testMoveTo()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")
    local hs = mockHs({ fooWindow, barWindow, bazWindow })
    local wm = new_wm.new(true, mockLogger(), hs, true)
    wm:start()

    hs.window._focusedWindow = bazWindow

    wm:moveFocusedTo(2)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                type = new_wm.__STACK,
                span = 1,
            },
            {
                type = new_wm.__PINNED,
                span = 1,
                title = bazWindow:title(),
                application = bazWindow:application():name()
            }}
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 60, y = 0, w = 60, h = 100 })
end

-- function testMoveToExtend()
--     local fooWindow = mockWindow(1, "Foo", "Foo")
--     local barWindow = mockWindow(2, "Bar", "Bar")
--     local bazWindow = mockWindow(3, "Baz", "Baz")
--     local hs = mockHs({ fooWindow, barWindow, bazWindow })
--     local wm = new_wm.new(true, mockLogger(), hs, true)

--     hs.window._focusedWindow = bazWindow

--     wm:moveFocusedTo(3)

--     lu.assertEquals(wm._current_layout[1].columns, {
--         {
--             type = new_wm.__STACK,
--             span = 1,
--         },
--         {
--             type = new_wm.__EMPTY,
--             span = 1
--         },
--         {
--             type = new_wm.__PINNED,
--             span = 1,
--             title = bazWindow:title(),
--             application = bazWindow:application():name()
--         }
--     })

--     lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
--     lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
--     lu.assertEquals(bazWindow._frame, { x = 80, y = 0, w = 40, h = 100 })
-- end

function testMoveToExistingPosition()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")
    local hs = mockHs({ fooWindow, barWindow, bazWindow })
    local wm = new_wm.new(true, mockLogger(), hs, true)
    wm:start()
    hs.window._focusedWindow = bazWindow

    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__EMPTY,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = bazWindow:title(),
                    application = bazWindow:application():name()
                }
            }
        }
    })

    wm:moveFocusedTo(2)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = bazWindow:title(),
                    application = bazWindow:application():name()
                },
                {
                    type = new_wm.__EMPTY,
                    span = 1
                },
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 40, y = 0, w = 40, h = 100 })
end

function testMoveToSamePosition()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")
    local hs = mockHs({ fooWindow, barWindow, bazWindow })
    local wm = new_wm.new(true, mockLogger(), hs, true)
    wm:start()
    hs.window._focusedWindow = bazWindow

    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = bazWindow:title(),
                    application = bazWindow:application():name()
                }
            }
        }
    })

    wm:moveFocusedTo(2)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = bazWindow:title(),
                    application = bazWindow:application():name()
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 60, y = 0, w = 60, h = 100 })
end

function testMoveToStack()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")
    local hs = mockHs({ fooWindow, barWindow, bazWindow })
    local wm = new_wm.new(true, mockLogger(), hs, true)
    wm:start()
    hs.window._focusedWindow = bazWindow

    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = bazWindow:title(),
                    application = bazWindow:application():name()
                }
            }
        }
    })

    wm:moveFocusedTo(1)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__EMPTY,
                    span = 1,
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
end

-- function testMoveVSplitToStack()
--     local fooWindow = mockWindow(1, "Foo", "Foo")
--     local barWindow = mockWindow(2, "Bar", "Bar")
--     local bazWindow = mockWindow(3, "Baz", "Baz")
--     local hs = mockHs({ fooWindow, barWindow, bazWindow })
--     local wm = new_wm.new(true, mockLogger(), hs, true)
--     wm:start()
--     hs.window._focusedWindow = bazWindow

--     wm:setLayout({
--         type = new_wm.__ROOT,
--         child = {
--             type = new_wm.__COLUMNS,
--             columns = {
--                 {
--                     type = new_wm.__STACK,
--                     span = 1
--                 },
--                 {
--                     type = new_wm["__ROWS "],
--                     span = 1,
--                     rows = {
--                         {
--                             type = new_wm.__PINNED,
--                             span = 1,
--                             title = bazWindow:title(),
--                             application = bazWindow:application():name()
--                         },
--                         {
--                             type = new_wm.__EMPTY,
--                             span = 1
--                         },
--                     }
--                 }
--             }
--         }
--     })

--     wm:moveFocusedTo(1)

--     lu.assertEquals(wm._current_layout[1], {
--         type = new_wm.__ROOT,
--         child = {
--             type = new_wm.__COLUMNS,
--             columns = {
--                 {
--                     type = new_wm.__STACK,
--                     span = 1
--                 },
--                 {
--                     type = new_wm["__ROWS "],
--                     span = 1,
--                     rows = {
--                         {
--                             type = new_wm.__EMPTY,
--                             span = 1
--                         },
--                         {
--                             type = new_wm.__EMPTY,
--                             span = 1
--                         },
--                     }
--                 }
--             }
--         }
--     })

--     lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
--     lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
--     lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
-- end

function testSetSpanOnPositionedWindow()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")
    local hs = mockHs({ fooWindow, barWindow, bazWindow })
    local wm = new_wm.new(true, mockLogger(), hs, true)
    wm:start()
    hs.window._focusedWindow = bazWindow

    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = bazWindow:title(),
                    application = bazWindow:application():name()
                }
            }
        }
    })

    wm:setFocusedColumnSpan(2)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__PINNED,
                    span = 2,
                    title = bazWindow:title(),
                    application = bazWindow:application():name()
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 40, y = 0, w = 80, h = 100 })
end

function testSetSpanOnStackWindow()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")
    local hs = mockHs({ fooWindow, barWindow, bazWindow })
    local wm = new_wm.new(true, mockLogger(), hs, true)
    wm:start()

    hs.window._focusedWindow = bazWindow

    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    wm:setFocusedColumnSpan(2)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 2,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 80, y = 0, w = 40, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 80, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 80, h = 100 })
end

function testSplit()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }), true)
    wm:start()
    wm:setSplits(2)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__EMPTY,
                    span = 1
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 60, h = 100 })

    wm:setSplits(3)
    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__EMPTY,
                    span = 1
                },
                {
                    type = new_wm.__EMPTY,
                    span = 1
                }
            }
        }
    })
    lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
end

function testSplitMultiple()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }), true)
    wm:start()
    wm:setSplits(3)
    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__EMPTY,
                    span = 1
                },
                {
                    type = new_wm.__EMPTY,
                    span = 1
                }
            }
        }
    })
    lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 40, h = 100 })
end

function testReduceSplit()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }), true)
    wm:start()
    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = bazWindow:title(),
                    application = bazWindow:application():name()
                }
            }
        }
    })

    wm:setSplits(2)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 60, y = 0, w = 60, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
end

function testReduceSplitMultiple()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }), true)
    wm:start()
    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                },
                { type = new_wm.__EMPTY, span = 1 },
                { type = new_wm.__EMPTY, span = 1 },
            }
        }
    })

    wm:setSplits(2)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 60, y = 0, w = 60, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
end

function testReduceSplitRepositionStack()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }), true)
    wm:start()
    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                },
                {
                    type = new_wm.__STACK,
                    span = 1
                }
            }
        }
    })

    wm:setSplits(1)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 120, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 120, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 120, h = 100 })
end

function testAddNewWindow()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow }), true)
    wm:start()
    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    wm:addWindow(bazWindow)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 60, y = 0, w = 60, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
end

function testRemoveWindow()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }), true)
    wm:start()
    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    wm:removeWindow(bazWindow)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 60, y = 0, w = 60, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
end

function testRemovePinnedWindow()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }), true)
    wm:start()
    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    wm:removeWindow(fooWindow)

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
end

-- function testSetLayoutNormalRefresh()
--     local fooWindow = mockWindow(1, "Foo", "Foo")
--     local barWindow = mockWindow(2, "Bar", "Bar")
--     local bazWindow = mockWindow(3, "Baz", "Baz")

--     local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }))
--     wm:start()
--     wm:setLayout({
--         columns = {
--             {
--                 type = new_wm.__STACK,
--                 span = 1
--             },
--             {
--                 type = new_wm.__WINDOW,
--                 span = 1,
--                 name = fooWindow:title(),
--                 window = fooWindow
--             },
--         }
--     }, true)

--     wm:setLayout({
--         columns = {
--             {
--                 type = new_wm.__STACK,
--                 span = 1
--             },
--         }
--     })

--     lu.assertEquals(wm._current_layout[1].columns, {
--         {
--             type = new_wm.__STACK,
--             span = 1,
--             windows = {
--                 [fooWindow:id()] = fooWindow,
--                 [barWindow:id()] = barWindow,
--                 [bazWindow:id()] = bazWindow
--             }
--         }
--     })

--     lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 120, h = 100 })
--     lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 120, h = 100 })
--     lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 120, h = 100 })
-- end

function testApplicationNotFound()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }), true)
    wm:start()
    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = "Unknown",
                    application = "Unknown",
                },
            }
        }
    })

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = "Unknown",
                    application = "Unknown",
                },
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
end

function testVSplit()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")

    local wm = new_wm.new(true, mockLogger(), mockHs({ fooWindow, barWindow, bazWindow }), true)
    wm:start()
    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1
                },
                {
                    type = new_wm.__ROWS,
                    span = 1,
                    rows = {
                        {
                            type = new_wm.__EMPTY,
                            span = 3
                        },
                        {
                            type = new_wm.__PINNED,
                            span = 1,
                            title = fooWindow:title(),
                            application = fooWindow:application():name()
                        },
                    }
                },
            }
        }
    })

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 1,
                },
                {
                    type = new_wm.__ROWS,
                    span = 1,
                    rows = {
                        {
                            type = new_wm.__EMPTY,
                            span = 3
                        },
                        {
                            type = new_wm.__PINNED,
                            span = 1,
                            title = fooWindow:title(),
                            application = fooWindow:application():name()
                        },
                    }
                },
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 60, y = 75, w = 60, h = 25 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 60, h = 100 })
end

function testToggleZoomFocusedWindow()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")
    local hs = mockHs({ fooWindow, barWindow, bazWindow })
    local wm = new_wm.new(true, mockLogger(), hs, true)
    wm:start()

    hs.window._focusedWindow = bazWindow

    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 2
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    wm._lastFocusedWindow = bazWindow

    wm:toggleZoomFocusedWindow()

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 2,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        },
        zoomed = {
            {
                type = new_wm.__PINNED,
                title = bazWindow:title(),
                application = bazWindow:application():name()
            }
        }
    })

    lu.assertEquals(fooWindow._frame, { x = 80, y = 0, w = 40, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 80, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 120, h = 100 })

    wm:toggleZoomFocusedWindow()

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 2,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        },
        zoomed = {
        }
    })
    lu.assertEquals(fooWindow._frame, { x = 80, y = 0, w = 40, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 80, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 80, h = 100 })
end

function testToggleFloatFocusedWindow()
    local fooWindow = mockWindow(1, "Foo", "Foo")
    local barWindow = mockWindow(2, "Bar", "Bar")
    local bazWindow = mockWindow(3, "Baz", "Baz")
    local hs = mockHs({ fooWindow, barWindow, bazWindow })
    local wm = new_wm.new(true, mockLogger(), hs, true)
    wm:start()

    hs.window._focusedWindow = bazWindow

    wm:setLayout({
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 2
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        }
    })

    wm._lastFocusedWindow = bazWindow

    wm:toggleFloatFocusedWindow()

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 2,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        },
        floats = {
            {
                type = new_wm.__PINNED,
                title = bazWindow:title(),
                application = bazWindow:application():name()
            }
        }
    })

    bazWindow:setFrame(mockGeometry.new(10, 10, 99, 99))

    lu.assertEquals(fooWindow._frame, { x = 80, y = 0, w = 40, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 80, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 10, y = 10, w = 99, h = 99 })

    wm:toggleFloatFocusedWindow()

    lu.assertEquals(wm._current_layout[1], {
        type = new_wm.__ROOT,
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 2,
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    title = fooWindow:title(),
                    application = fooWindow:application():name()
                }
            }
        },
        floats = {
        }
    })
    lu.assertEquals(fooWindow._frame, { x = 80, y = 0, w = 40, h = 100 })
    lu.assertEquals(barWindow._frame, { x = 0, y = 0, w = 80, h = 100 })
    lu.assertEquals(bazWindow._frame, { x = 0, y = 0, w = 80, h = 100 })
end

lu.run()