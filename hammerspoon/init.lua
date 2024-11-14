-- TODO
-- - Window Manager
-- -- Layout Editor
-- -- Saving/Loading Layouts
-- -- Vertical splits
-- -- Multi space support
-- -- Multi screen support
-- -- Floats
-- -- Zoom

package.path = package.path .. ";./?.lua"
require("lock_screen")

NUMBER_CODES = {
}
for i = 1, 9 do
    NUMBER_CODES[tostring(i)] = true
end

local function isAlphabetChar(char)
    local byte = string.byte(char)
    return (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)
end

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

local new_wm = require("new_new_wm")

DefaultLayouts = {
    {
        type = new_wm.__ROOT,
        name = "VLC",
        quickKey = "v",
        child = {
            type = new_wm.__COLUMNS,
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
        }
    },
    {
        type = new_wm.__ROOT,
        name = "Plex",
        quickKey = "p",
        child = {
            type = new_wm.__COLUMNS,
            columns = {
                {
                    type = new_wm.__STACK,
                    span = 3
                },
                {
                    type = new_wm.__PINNED,
                    span = 1,
                    application = "Plex"
                }
            }
        }
    },
    {
        type = new_wm.__ROOT,
        name = "Split",
        quickKey = "s",
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
                }
            }
        }
    }
}

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
        modalCommander:postMessageToWebview({ type = "windowManagement", layouts = DefaultLayouts })
        modalCommander:postMessageToWebview(siteBlockerState)
    end,
    onMessage = function(modalCommander, message)
        if message.type == "siteBlocker" then
            modalCommander:hideBrowser()
            SiteBlocker:toggleSiteBlocking()
        elseif message.type == "windowManagementSelectLayout" then
            for _, layout in ipairs(DefaultLayouts) do
                if layout.quickKey == message.quickKey then
                    WM:setLayout(layout)
                    break
                end
            end
        end
    end,
    onShow = function(modalCommander)
        local siteBlockerState = SiteBlocker:getState()
        siteBlockerState.type = "siteBlocker"
        modalCommander:postMessageToWebview(siteBlockerState)
        modalCommander:postMessageToWebview({ type = "windowManagement", layouts = DefaultLayouts, currentLayout = WM
        :getLayout() })
    end
})

ModalCommander:start()

WM = new_wm.new("info")
WM:start()

WM:setLayout(DefaultLayouts[1])
