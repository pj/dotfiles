-- TODO
-- - Saving/Loading Layouts
-- - Modal controls
-- - Test site blocking changes
-- - Web interface for controls

package.path = package.path .. ";./?.lua"
require("site_blocker")
require("lock_screen")

local new_wm = require("new_wm")

WM = new_wm.new(true)

local window_manager_watcher = require("window_manager_watcher")

WMWatcher = window_manager_watcher.new(WM, true)


local Layouts = {
    default = {
        columns = { {
            type = new_wm.__STACK,
            span = 1
        } }
    },
    v = {
        columns = {
            {
                type = new_wm.__STACK,
                span = 3
            },
            {
                type = new_wm.__WINDOW,
                span = 1,
                application = "org.videolan.vlc"
            }
        }
    },
    p = {
        columns = {
            {
                type = new_wm.__STACK,
                span = 3
            },
            {
                type = new_wm.__WINDOW,
                span = 1,
                application = "Plex"
            }
        }
    },
    s = {
        columns = {
            {
                type = new_wm.__STACK,
                span = 1
            },
            {
                type = new_wm.__EMPTY,
                span = 1,
            }
        }
    },
    f = {
        columns = {
            {
                type = new_wm.__STACK,
                span = 1
            }
        }
    }
}

-- WM:setLayout(Layouts["f"], true)
WM:setLayout(Layouts["p"], true)

local regular_key_modifier = require("regular_key_modifier")

NUMBER_CODES = {
}
for i = 1, 9 do
    NUMBER_CODES[tostring(i)] = true
end

local function isAlphabetChar(char)
    local byte = string.byte(char)
    return (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)
end

WindowManagerKey = regular_key_modifier.new(true)
WindowManagerKey:start("f16", function(event)
    local keycode = hs.keycodes.map[event:getKeyCode()]
    if NUMBER_CODES[keycode] then
        local flags = event:getFlags()
        if flags["ctrl"] then
            WM:setColumnSpan(tonumber(keycode))
        elseif flags["alt"] then
            WM:setSplits(tonumber(keycode))
        else
            WM:moveFocusedTo(tonumber(keycode))
        end
        return true
    elseif isAlphabetChar(keycode) then
        local layout = Layouts[keycode]
        if layout == nil then
            hs.printf("No layout for key: %s", keycode)
            return
        end
        WM:setLayout(layout)
        return true
    end
end)

-- c = require("hs.canvas")
-- a = c.new{ x = 100, y = 100, h = 100, w = 100 }:show()
-- a:insertElement({ type = "rectangle", id = "part1", fillColor = { blue = 1 } })
-- a:insertElement({ type = "circle", id = "part2", fillColor = { green = 1 } })

local ControlModal = hs.hotkey.modal.new("", "f15")

ModalCanvas = nil
Browser = nil

function ControlModal:entered()
    hs.printf("Entered")
    Browser = hs.webview.newBrowser({ x = 100, y = 100, h = 100, w = 100 })
    Browser:url(string.format("file://%s", hs.fs.pathToAbsolute("wmui/index.html")))
    
    Browser:show()
    -- local canvas = require("hs.canvas")
    -- ModalCanvas = canvas.new{ x = 100, y = 100, h = 100, w = 100 }:show()
    -- ModalCanvas:insertElement({ type = "rectangle", id = "part1", fillColor = { blue = 1 } })
    -- ModalCanvas:insertElement({ type = "circle", id = "part2", fillColor = { green = 1 } })
end

-- ControlModal:bind("", "c", function()
--     hs.alert("Setting target column")
--     ControlModal:exit()
-- end)

ControlModal:bind("", "escape", function()
    hs.alert("Escape")
    -- ModalCanvas:delete()
    Browser:hide()
    ControlModal:exit()
end)

-- ControlModal:bind("", "enter", function()
--     hs.alert("Enter")
--     ControlModal:exit()
-- end)