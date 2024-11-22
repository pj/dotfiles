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
        name = "VLC",
        quickKey = "v",
        screens = {
            {
                ["MSI PS341WU"] = {
                    type = new_wm.__COLUMNS,
                    columns = {
                        {
                            type = new_wm.__STACK,
                            percentage = 75
                        },
                        {
                            type = new_wm.__ROWS,
                            percentage = 25,
                            rows = {
                                {
                                    type = new_wm.__PINNED,
                                    percentage = 50,
                                    application = "VLC"
                                },
                                {
                                    type = new_wm.__PINNED,
                                    percentage = 50,
                                    application = "Podcasts"
                                }
                            }
                        }
                    }
                },
                ["CX101"] = {
                    type = new_wm.__PINNED,
                    percentage = 100,
                    application = "Amazon Music"
                },
            },
            {
                ["MSI PS341WU"] = {
                    type = new_wm.__COLUMNS,
                    columns = {
                        {
                            type = new_wm.__STACK,
                            percentage = 75
                        },
                        {
                            type = new_wm.__ROWS,
                            percentage = 25,
                            rows = {
                                {
                                    type = new_wm.__PINNED,
                                    percentage = 50,
                                    application = "VLC"
                                },
                                {
                                    type = new_wm.__PINNED,
                                    percentage = 50,
                                    application = "Podcasts"
                                }
                            }
                        }
                    }
                }
            },
            {
                ["Built-in Retina Display"] = {
                    type = new_wm.__COLUMNS,
                    columns = {
                        {
                            type = new_wm.__STACK,
                            percentage = 60
                        },
                        {
                            type = new_wm.__PINNED,
                            percentage = 40,
                            application = "VLC"
                        }
                    }
                }
            },
            {
                [new_wm.__SCREEN_PRIMARY] = {
                    type = new_wm.__COLUMNS,
                    columns = {
                        {
                            type = new_wm.__STACK,
                            percentage = 75
                        },
                        {
                            type = new_wm.__PINNED,
                            percentage = 25,
                            application = "VLC"
                        }
                    }
                }
            },
        }
    },
    {
        name = "Plex",
        quickKey = "p",
        screens = {
            {
                [new_wm.__SCREEN_PRIMARY] = {
                    type = new_wm.__COLUMNS,
                    columns = {
                        {
                            type = new_wm.__STACK,
                            percentage = 75
                        },
                        {
                            type = new_wm.__PINNED,
                            percentage = 25,
                            application = "Plex"
                        }
                    }
                }
            }
        }
    },
    {
        name = "Split",
        quickKey = "s",
        screens = {
            {
                [new_wm.__SCREEN_PRIMARY] = {
                    type = new_wm.__COLUMNS,
                    columns = {
                        {
                            type = new_wm.__STACK,
                            percentage = 50
                        },
                        {
                            type = new_wm.__EMPTY,
                            percentage = 50
                        }
                    }
                }
            }
        }
    },
    {
        name = "Full Screen",
        quickKey = "f",
        screens = {
            {
                [new_wm.__SCREEN_PRIMARY] = {
                    type = new_wm.__COLUMNS,
                    columns = {
                        {
                            type = new_wm.__STACK,
                            percentage = 100
                        },
                    }
                },
            }
        }
    },
}

WM = new_wm.new("info")
WM:start()

WM:setLayout(DefaultLayouts[1])

hs.printf("Starting web server in directory %s", os.getenv("HOME") .. "/dotfiles/hammerspoon/wmui/dist")
local webServer = hs.httpserver.hsminweb.new(os.getenv("HOME") .. "/dotfiles/hammerspoon/wmui/dist")
webServer:start()

hs.printf("Web server started on port %d", webServer:port())

local modal_commander = require("modal_commander")
function UpdateLayouts(modalCommander)
    local currentScreens = {}
    for _, screen in ipairs(hs.screen.allScreens()) do
        table.insert(currentScreens, { name = screen:name(), primary = screen:id() == hs.screen.primaryScreen():id() })
    end
    modalCommander:postMessageToWebview({
        type = "windowManagement",
        layouts = DefaultLayouts,
        currentLayout = WM:getLayout(),
        currentLayoutName = WM:getLayout().name,
        currentScreens = currentScreens
    })
end

ModalCommander = modal_commander.new({
    debug = true,
    -- appAddress = "http://127.0.0.1:5173",
    appAddress = "http://127.0.0.1:" .. webServer:port(),
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
        UpdateLayouts(modalCommander)
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
        UpdateLayouts(modalCommander)
    end
})

ModalCommander:start()

hs.hotkey.bind({ "cmd", "ctrl" }, "t", nil, function()
    ModalCommander:focusBrowser()
end)
