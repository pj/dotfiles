-- TODO
-- - Window Manager
-- -- Actions - move, set columns, increase/decrease span
-- -- Layout Editor
-- -- Saving/Loading Layouts

package.path = package.path .. ";./?.lua"
require("lock_screen")

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
        screens = {
            {
                type = new_wm.__SCREEN,
                name = "MSI PS341WU",
                root = {
                    type = new_wm.__COLUMNS,
                    columns = {
                        {
                            type = new_wm.__STACK,
                            span = 3
                        },
                        {
                            type = new_wm.__ROWS,
                            span = 1,
                            rows = {
                                {
                                    type = new_wm.__PINNED,
                                    span = 1,
                                    application = "VLC"
                                },
                                {
                                    type = new_wm.__PINNED,
                                    span = 1,
                                    application = "Podcasts"
                                }
                            }
                        }
                    }
                }
            },
            {
                type = new_wm.__SCREEN,
                name = "CX101",
                root = {
                    type = new_wm.__PINNED,
                    span = 1,
                    application = "Amazon Music"
                }
            }
        }
    },
    {
        type = new_wm.__ROOT,
        name = "Plex",
        quickKey = "p",
        screens = {
            {
                type = new_wm.__SCREEN,
                name = "MSI PS341WU",
                root = {
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
            }
        }
    },
    {
        type = new_wm.__ROOT,
        name = "Split",
        quickKey = "s",
        screens = {
            {
                type = new_wm.__SCREEN,
                name = "MSI PS341WU",
                root = {
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
        elseif message.type == "windowManagementZoomToggle" then
            WM:toggleZoomFocusedWindow()
        elseif message.type == "windowManagementFloatToggle" then
            WM:toggleFloatFocusedWindow()
        end
    end,
    onShow = function(modalCommander)
        local siteBlockerState = SiteBlocker:getState()
        siteBlockerState.type = "siteBlocker"
        modalCommander:postMessageToWebview(siteBlockerState)
        modalCommander:postMessageToWebview({
            type = "windowManagement",
            layouts = DefaultLayouts,
            currentLayout = WM:getLayout()
        })
    end
})

ModalCommander:start()

WM = new_wm.new("info")
WM:start()

WM:setLayout(DefaultLayouts[1])

hs.hotkey.bind({"cmd", "ctrl"}, "t", nil, function()
    ModalCommander:focusBrowser()
end)
