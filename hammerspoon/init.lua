package.path = package.path .. ";./?.lua"
require("old_wm")
require("site_blocker")
require("lock_screen")

local window_control = "f16"

local new_wm = require("new_wm")

local wm = new_wm.new(true)

-- Bind Movements
-- local movement_modal = hs.hotkey.modal.new("", window_control)
-- movement_modal:entered(function() hs.printf("movement modal entered") end)
-- movement_modal:exited(function() hs.printf("movement modal exited") end)
-- for i = 1, 4 do 
--     movement_modal:bind(
--         "",
--         tostring(i),
--         function()
--             new_wm:_move_focused_to(i)
--             movement_modal:exit()
--         end
--     )
-- end


NUMBER_CODES = {
}
for i = 1,9 do
    NUMBER_CODES[tostring(i)] = true
end

local function isAlphabetChar(char)
    local byte = string.byte(char)
    return (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)
end

layouts = {
    default = {
        columns = {{
            type = new_wm.__STACK,
            span = 1
        }}
    },
    v = {
        columns = {
            {
                type = new_wm.__STACK,
                span = 3
            },
            {
                type = new_wm.__APPLICATION,
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
                type = new_wm.__APPLICATION,
                span = 1,
                application = "PLEX"
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

wm:setLayout(layouts["default"])

ControlPressed = false
EventTapper = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
    local eventType = event:getType()
    if eventType == hs.eventtap.event.types.keyDown then
        local keycode = hs.keycodes.map[event:getKeyCode()]
        if keycode == window_control then
            ControlPressed = true
            hs.printf("control pressed down")
        elseif NUMBER_CODES[keycode] and ControlPressed then
            local flags = event:getFlags()
            if flags["ctrl"] then
                wm:setColumnSpan(tonumber(keycode))
            elseif flags["alt"] then
                wm:setSplits(tonumber(keycode))
            else
                wm:moveFocusedTo(tonumber(keycode))
            end
            ControlPressed = false
        elseif ControlPressed and isAlphabetChar(keycode) then
            local layout = layouts[keycode]
            if layout == nil then
                hs.printf("No layout for key: %s", keycode)
                return
            end
            wm:setLayout(layout)
            ControlPressed = false
        end
    elseif eventType == hs.eventtap.event.types.keyUp then
        local keycode = hs.keycodes.map[event:getKeyCode()]
        if keycode == window_control then
            ControlPressed = false
            hs.printf("control pressed up")
        end
    end

    hs.printf("ControlPressed: %s", ControlPressed)
end)

EventTapper:start()

-- local profile_data = {}
-- 
-- local function hook(event)
--     local info = debug.getinfo(2, "nS")
--     local name = info.name or "unknown"
--     
--     if event == "call" then
--         if not profile_data[name] then
--             profile_data[name] = { calls = 0, time = 0 }
--         end
--         profile_data[name].start_time = os.clock()
--     elseif event == "return" and profile_data[name] then
--         local diff = os.clock() - profile_data[name].start_time
--         profile_data[name].calls = profile_data[name].calls + 1
--         profile_data[name].time = profile_data[name].time + diff
--     end
-- end
-- 
-- function start_profiling()
--     debug.sethook(hook, "cr")  -- Hook on function call and return
-- end
-- 
-- function stop_profiling()
--     debug.sethook()  -- Stop the hook
-- end
-- 
-- function print_profile_data()
--     for name, data in pairs(profile_data) do
--         print(string.format("Function '%s' - Calls: %d, Total Time: %.6f seconds", name, data.calls, data.time))
--     end
-- end
-- 
-- -- Example usage
-- start_profiling()
-- 
-- wm:setLayout(layouts["v"])
-- 
-- stop_profiling()
-- print_profile_data()
-- 


-- Bind layouts to keys
-- for key, value in pairs(layouts) do
--     hs.hotkey.bind(obj.standard_prefix, key, function() obj._set_layout(key, value) end)
-- end

-- Bind splits
-- local splits_modal = hs.hotkey.modal.new({"alt"}, window_control)
-- for i = 1, 4 do 
--     splits_modal:bind(nil, tostring(i), function() new_wm:_set_splits(i) end)
-- end

-- Bind span of focused
-- local span_modal = hs.hotkey.modal.new({"ctrl"}, window_control)
-- for i = 1, 4 do 
--     span_modal:bind(nil, tostring(i), function() new_wm:_set_column_span(i) end)
-- end

