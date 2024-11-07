-- TODO
-- - Window Manager
-- -- Vertical splits
-- -- Floats
-- -- Zoom
-- -- Saving/Loading Layouts

package.path = package.path .. ";./?.lua"
require("lock_screen")

-- local new_wm = require("new_wm")

-- WM = new_wm.new(true)

-- Layouts = {
--     default = {
--         columns = {
--             {
--                 type = new_wm.__STACK,
--                 span = 1
--             }
--         }
--     },
--     v = {
--         columns = {
--             {
--                 type = new_wm.__STACK,
--                 span = 3
--             },
--             {
--                 type = new_wm.__WINDOW,
--                 span = 1,
--                 application = "org.videolan.vlc"
--             }
--         }
--     },
--     p = {
--         columns = {
--             {
--                 type = new_wm.__STACK,
--                 span = 3
--             },
--             {
--                 type = new_wm.__WINDOW,
--                 span = 1,
--                 application = "Plex"
--             }
--         }
--     },
--     s = {
--         columns = {
--             {
--                 type = new_wm.__STACK,
--                 span = 1
--             },
--             {
--                 type = new_wm.__EMPTY,
--                 span = 1,
--             }
--         }
--     },
--     f = {
--         columns = {
--             {
--                 type = new_wm.__STACK,
--                 span = 1
--             }
--         }
--     }
-- }

-- -- WM:setLayout(Layouts["f"], true)
-- WM:setLayout(Layouts["v"], true)

-- local regular_key_modifier = require("regular_key_modifier")

NUMBER_CODES = {
}
for i = 1, 9 do
    NUMBER_CODES[tostring(i)] = true
end

local function isAlphabetChar(char)
    local byte = string.byte(char)
    return (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)
end

-- local mash = { "ctrl", "cmd" }

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

local modal_commander = require("modal_commander")
ModalCommander = modal_commander.new({
    debug = true,
    appAddress = "http://127.0.0.1:5173",
    periodicUpdateInterval = 60,
    onPeriodicUpdate = function(modalCommander)
        local siteBlockerState = SiteBlocker:getState()
        siteBlockerState.type = "siteBlocker"
        hs.printf("Periodic update: Posting site blocker state: %s", hs.inspect(siteBlockerState))
        modalCommander:postMessageToWebview(siteBlockerState)
    end,
    onStart = function(modalCommander)
        local siteBlockerState = SiteBlocker:getState()
        siteBlockerState.type = "siteBlocker"
        hs.printf("Starting: Posting site blocker state: %s", hs.inspect(siteBlockerState))
        modalCommander:postMessageToWebview(siteBlockerState)
    end,
    onMessage = function(modalCommander, message)
        if message.type == "siteBlocker" then
            modalCommander:hideBrowser()
            SiteBlocker:toggleSiteBlocking()
        end
    end,
    onShow = function(modalCommander)
        local siteBlockerState = SiteBlocker:getState()
        siteBlockerState.type = "siteBlocker"
        hs.printf("Showing: Posting site blocker state: %s", hs.inspect(siteBlockerState))
        modalCommander:postMessageToWebview(siteBlockerState)
    end
})

ModalCommander:start()

local new_wm = require("new_new_wm")
WM = new_wm.new("info")
WM:start()

WM:setLayout({
    columns = {
        {
            type = new_wm.__STACK,
            span = 3
        },
        {
            type = new_wm.__PINNED,
            span = 1,
            application = "VLC"
        }
    }
})
