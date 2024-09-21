package.path = package.path .. ";./?.lua"
require("old_wm")
require("site_blocker")
require("lock_screen")

local window_control = "f16"

local new_wm = require("new_wm")

new_wm:init(true)

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
        columns = {
            type = new_wm.__STACK,
            span = 1
        }
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
    }
}

new_wm:addCurrentScreen(layouts["default"])

ControlPressed = false
local eventTapper = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
    local eventType = event:getType()
    if eventType == hs.eventtap.event.types.keyDown then
        local keycode = hs.keycodes.map[event:getKeyCode()]
        if keycode == window_control then
            ControlPressed = true
        elseif NUMBER_CODES[keycode] and ControlPressed then
            local flags = event:getFlags()
            if flags["ctrl"] then
                new_wm:set_column_span(tonumber(keycode))
            elseif flags["alt"] then
                new_wm:set_splits(tonumber(keycode))
            else
                new_wm:move_focused_to(tonumber(keycode))
            end
        elseif ControlPressed and isAlphabetChar(keycode) then
            new_wm:set_layout(layous[keycode])
        end
    elseif eventType == hs.eventtap.event.types.keyUp then
        local keycode = hs.keycodes.map[event:getKeyCode()]
        if keycode == window_control then
            ControlPressed = false
        end
    end
end)

-- eventTapper:start()

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

