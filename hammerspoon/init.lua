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
require("lock_screen")

local new_wm = require("new_wm")

WM = new_wm.new(true)

local window_manager_watcher = require("window_manager_watcher")

WMWatcher = window_manager_watcher.new(WM, true)

Layouts = {
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
WM:setLayout(Layouts["v"], true)

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

-- WindowManagerKey = regular_key_modifier.new(true)
-- WindowManagerKey:start("f16", function(event)
--     local keycode = hs.keycodes.map[event:getKeyCode()]
--     if NUMBER_CODES[keycode] then
--         local flags = event:getFlags()
--         if flags["ctrl"] then
--             WM:setColumnSpan(tonumber(keycode))
--         elseif flags["alt"] then
--             WM:setSplits(tonumber(keycode))
--         else
--             WM:moveFocusedTo(tonumber(keycode))
--         end
--         return true
--     elseif isAlphabetChar(keycode) then
--         local layout = Layouts[keycode]
--         if layout == nil then
--             hs.printf("No layout for key: %s", keycode)
--             return
--         end
--         WM:setLayout(layout)
--         return true
--     end
-- end)

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

Browser = nil
BrowserReady = false
BrowserVisible = false

local function postMessageToWebview(message)
    if Browser == nil then
        return
    end
    Browser:evaluateJavaScript([[
        window.postMessage(]] .. hs.json.encode(message) .. [[, 'http://127.0.0.1:5173');
    ]]

    -- ,
    -- function(result, error)
    --     hs.printf("Evaluated JavaScript: %s", hs.inspect(result))
    --     hs.printf("Evaluated JavaScript error: %s", hs.inspect(error))
    -- end
    )
end


local function UpdateBrowserState()
    local siteBlockerState = SiteBlocker:getState()
    siteBlockerState.type = "siteBlocker"
    postMessageToWebview(siteBlockerState)
end

local UpdateStateTimer = hs.timer.doEvery(
    60,
    function()
        hs.printf("Updating browser state")
        if Browser ~= nil and BrowserVisible then
            UpdateBrowserState()
        end
    end
)

UpdateStateTimer:start()

local function receiveMessageFromWebview(event)
    if event.body.type == "uiReady" then
        BrowserReady = true
        postMessageToWebview({ type = "hammerspoonReady" })
        UpdateBrowserState()
    elseif event.body.type == "exit" then
        if Browser ~= nil then
            Browser:hide()
            BrowserVisible = false
            postMessageToWebview({ type = "resetState" })
        end
    elseif event.body.type == "log" then
        hs.printf("Log: %s", hs.inspect(event.body))
    elseif event.body.type == "siteBlocker" then
        SiteBlocker:toggleSiteBlocking()
        UpdateBrowserState()
    end
end

local function createModalCommanderWebview()
    local usercontent = hs.webview.usercontent.new("wmui")
    usercontent:setCallback(receiveMessageFromWebview)
    local screenFrame = hs.screen.mainScreen():frame()
    local middleX = screenFrame.x + screenFrame.w / 2
    local x = middleX - 1000 / 2
    local middleY = screenFrame.y + screenFrame.h / 2
    local y = middleY - 300 / 2
    Browser = hs.webview.new(
        { x = x, y = y, h = 300, w = 1000 },
        { developerExtrasEnabled = true },
        usercontent
    )
    Browser:url("http://127.0.0.1:5173")
    Browser:titleVisibility('hidden'):allowTextEntry(true):allowGestures(true)
end

local function focusBrowser()
    if Browser ~= nil and not BrowserVisible then
        UpdateBrowserState()
        Browser:show()
        Browser:bringToFront()
        Browser:hswindow():focus()
        BrowserVisible = true
    end
end

WMUIEventTapper = hs.eventtap.new(
    {
        hs.eventtap.event.types.keyDown,
        hs.eventtap.event.types.keyUp
    },
    function(event)
        local eventType = event:getType()
        if eventType == hs.eventtap.event.types.keyDown then
            local keycode = hs.keycodes.map[event:getKeyCode()]
            if keycode == 'f15' then
                if Browser == nil then
                    createModalCommanderWebview()
                    focusBrowser()
                else
                    if BrowserVisible then
                        Browser:hide()
                        postMessageToWebview({ type = "resetState" })
                        BrowserVisible = false
                    else
                        focusBrowser()
                    end
                end
                return true
            end
        end

        return false
    end
)

WMUIEventTapper:start()
