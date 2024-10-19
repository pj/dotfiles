-- TODO
-- - Modal controls
-- - Test site blocking changes
-- - Web interface for controls
-- - Window Manager
-- -- Vertical splits
-- -- Floats
-- -- Zoom
-- -- Saving/Loading Layouts

package.path = package.path .. ";./?.lua"
require("site_blocker")
require("lock_screen")

local new_wm = require("new_wm")

WM = new_wm.new(true)

local window_manager_watcher = require("window_manager_watcher")

WMWatcher = window_manager_watcher.new(WM, true)

local Layouts = {
    default = {
        columns = {
            {
                type = new_wm.__STACK,
                span = 1
            }
        }
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

Browser = nil
BrowserReady = false
BrowserVisible = false

local function postMessageToWebview(message)
    if Browser == nil then
        return
    end
    Browser:evaluateJavaScript([[
        window.postMessage(]] .. hs.json.encode(message) .. [[, 'http://localhost:3000');
    ]], function(result, error)
        hs.printf("Evaluated JavaScript: %s", hs.inspect(result))
        hs.printf("Evaluated JavaScript error: %s", hs.inspect(error))
    end)
end

local function createModalCommanderWebview()
    local usercontent = hs.webview.usercontent.new("wmui")
    usercontent:setCallback(function(event)
        hs.printf("Event: %s", hs.inspect(event.body))
        if event.body.type == "uiReady" then
            BrowserReady = true
            postMessageToWebview({ type = "hammerspoonReady" })
        end
        if event.body.type == "uiDone" then
            if Browser ~= nil then
                Browser:hide()
                BrowserVisible = false
            end
        end
        if event.body.type == "log" then
            hs.printf("Log: %s", event.log)
        end
    end)
    Browser = hs.webview.newBrowser({ x = 100, y = 100, h = 400, w = 600 }, {}, usercontent)
    Browser:url("http://localhost:3000")
end

ModalCommanderKey = regular_key_modifier.new(
    true,
    function()
        if Browser == nil then
            createModalCommanderWebview()
            if Browser ~= nil and not BrowserVisible then
                Browser:show()
                Browser:bringToFront()
                BrowserVisible = true
            end
        end
    end,
    function()
        if Browser ~= nil then
            Browser:hide()
            Browser:delete()
            Browser = nil
            BrowserVisible = false
        end
    end
)
ModalCommanderKey:start("f15", function(event)
    -- hs.printf("key pressed: %s", hs.inspect(event))
    local keycode = hs.keycodes.map[event:getKeyCode()]
    hs.printf("keycode: %s", keycode)
    if keycode == "escape" or keycode == "f15" then
        if Browser ~= nil then
            Browser:hide()
            Browser:delete()
            Browser = nil
            BrowserVisible = false
        end

        return true
    else
        if Browser ~= nil and not BrowserVisible then
            Browser:show()
            Browser:bringToFront()
            BrowserVisible = true
        end
        return false
    end
end)

-- local ControlModal = hs.hotkey.modal.new("", "f15")

-- ModalCanvas = nil

-- function ControlModal:entered()
--     local usercontent = hs.webview.usercontent.new("wmui")
--     usercontent:setCallback(function(event)
--         hs.printf("Event: %s", hs.inspect(event))
--     end)
--     Browser = hs.webview.newBrowser({ x = 100, y = 100, h = 400, w = 600 }, {}, usercontent)
--     Browser:url("http://localhost:3000")
--     function postMessageToWebview(message)
--         Browser:evaluateJavaScript([[
--         window.postMessage('hello from evaluateJavaScript', 'http://localhost:3000');
--         ]], function(result, error)
--             hs.printf("Evaluated JavaScript: %s", hs.inspect(result))
--             hs.printf("Evaluated JavaScript error: %s", hs.inspect(error))
--         end)
--     end

--     Browser:show()
--     Browser:bringToFront()
--     Browser:navigationCallback(function(event)
--         hs.printf("Navigation event: %s", hs.inspect(event))
--     end)
-- end

-- ControlModal:bind("", "escape", function()
--     Browser:hide()
--     ControlModal:exit()
-- end)

-- ControlModal:bind("", "f15", function()
--     Browser:hide()
--     ControlModal:exit()
-- end)

-- ControlModal:bind("", "s", function()
--     postMessageToWebview({ message = "Hello from Hammerspoon" })
-- end)

local mash = { "ctrl", "cmd" }

-- hs.hotkey.bind(mash, "c", function() tiling.cycleLayout() end)
-- hs.hotkey.bind(mash, "j", function() tiling.cycle(1) end)
-- hs.hotkey.bind(mash, "k", function() tiling.cycle(-1) end)
-- hs.hotkey.bind(mash, "space", function() tiling.promote() end)
-- hs.hotkey.bind(mash, "f", function() tiling.goToLayout("fullscreen") end)
-- hs.hotkey.bind(mash, "p", function() tiling.goToLayout("plex") end)
-- hs.hotkey.bind(mash, "v", function() tiling.goToLayout("vlc") end)
-- hs.hotkey.bind(mash, "r", function() hs.alert('retiling'); tiling.retile() end)

local site_blocker = require("site_blocker")

local settingsStore = {}
function settingsStore.set(key, value)
    hs.settings.set(key, value)
end

function settingsStore.get(key)
    return hs.settings.get(key)
end

SiteBlocker = site_blocker.new({
    debug = true,
    store = settingsStore,
    timeLimit = 60,
    weekendTimeLimit = 120,
    blocklistFilename = "/Users/pauljohnson/.blocklist",
    permanentBlocklistFilename = "/Users/pauljohnson/.permanent_blocklist",
    hostsTemplate = "/Users/pauljohnson/.hosts_template",
    hostsFilePath = "/etc/hosts",
    closeTabScriptFilename = "/Users/pauljohnson/dotfiles/hammerspoon/tabCloser.scpt"
})

hs.hotkey.bind(mash, "t", function() SiteBlocker:toggleSiteBlocking() end)
