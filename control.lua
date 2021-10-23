-- require("custom_ui")
-- Variables

-- local is_enabled = false
local moving = false
local placing = true
local placed = 0
local gapped = 0

-- Gui Section


local function build_sprite_buttons(player)
    local player_global = global.players[player.index]
    local button_table = player_global.elements.button_table
    button_table.clear()

    local total_offset = player_global.max_place+player_global.max_gap
    local total = placed+gapped-1
    -- game.print(total_offset)
    local sprite_name = "inserter"
    -- game.print(player.cursor_stack)
    -- if player.cursor_stack.name == nil then
    --     sprite_name = "inserter"
    -- else
    --     sprite_name = player.cursor_stack.name
    -- end
    -- game.print(player)
    for i = 0, player_global.max_place-1 do        
        -- game.print(sprite_name)
        -- game.print("total: "..tostring(total))
        -- local button_style = (i+1 == total) and "yellow_slot_button" or "recipe_slot_button"
        button_table.add{type="sprite-button", sprite=("item/" .. sprite_name), style=button_style}
    end
    -- total = total+1
    for i = player_global.max_place, total_offset-1 do        
        -- game.print("total: "..tostring(total))
        -- game.print("i: "..tostring(i))
        -- local button_style = (i == total) and "yellow_slot_button" or "recipe_slot_button"
        button_table.add{type="sprite-button", sprite=("virtual-signal/signal-dot"), style=button_style}
    end
end

local function build_interface(player)
    local player_global = global.players[player.index]
    local screen_element = player.gui.screen
    local main_frame = screen_element.add{type="frame", name="main_frame", caption={"better_placer.title"}}
    main_frame.style.size = {440, 200}
    -- main_frame.auto_center = true

    player.opened = main_frame
    player_global.elements.main_frame = main_frame

    local content_frame = main_frame.add{type="frame", name="content_frame", direction="vertical", style="content_frame"}
    local controls_flow = content_frame.add{type="flow", name="controls_flow", direction="horizontal", style="controls_flow"}    
    controls_flow.style.bottom_margin = 5
    local initial_button_count_gap = player_global.max_gap
    local initial_button_count_place = player_global.max_place

    -- gap offset
    local label_offset = controls_flow.add{type="label", caption="Gap Offset:",}
    label_offset.style.right_padding = 8
    local controls_slider_gap = controls_flow.add{type="slider", name="controls_slider_gap", value=initial_button_count_gap, minimum_value=1, maximum_value=6, style="notched_slider"}
    
    player_global.elements.controls_slider_gap = controls_slider_gap
    local controls_textfield_gap = controls_flow.add{type="textfield", name="controls_textfield_gap", text=tostring(initial_button_count_gap), numeric=true, allow_decimal=false, allow_negative=false, style="controls_textfield"}
    player_global.elements.controls_textfield_gap = controls_textfield_gap

    -- place offset
    
    local controls_flow_place = content_frame.add{type="flow", name="controls_flow_place", direction="horizontal", style="controls_flow"}    
    controls_flow_place.add{type="label", caption="Place Offset:",}
    local controls_slider_place = controls_flow_place.add{type="slider", name="controls_slider_place", value=initial_button_count_place, minimum_value=1, maximum_value=6, style="notched_slider"}
    
    player_global.elements.controls_slider_place = controls_slider_place
    local controls_textfield_place = controls_flow_place.add{type="textfield", name="controls_textfield_place", text=tostring(initial_button_count_place), numeric=true, allow_decimal=false, allow_negative=false, style="controls_textfield"}
    player_global.elements.controls_textfield_place = controls_textfield_place

    -- Frame
    local button_frame = content_frame.add{type="frame", name="button_frame", direction="horizontal", style="deep_frame"}
    local button_table = button_frame.add{type="table", name="button_table", column_count=8, style="filter_slot_table"}
    player_global.elements.button_table = button_table
    build_sprite_buttons(player)
end

local function initialize_global(player)
    global.players[player.index] = { is_enabled = false, max_gap = 3, max_place = 3, elements = {} }

end

local function toggle_interface(player)
    local player_global = global.players[player.index]
    local main_frame = player_global.elements.main_frame

    if main_frame == nil then
        build_interface(player)
        player_global.is_enabled = true
    else
        main_frame.destroy()
        player_global.elements = {}
        player_global.is_enabled = false
    end
    -- game.print(player_global.is_enabled)
end


-- Make sure the intro cinematic of freeplay doesn't play every time we restart
-- This is just for convenience, don't worry if you don't understand how this works
script.on_init(function()
    -- local freeplay = remote.interfaces["freeplay"]
    -- if freeplay then  -- Disable freeplay popup-message
    --     if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
    --     if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
    -- end

    global.players = {}
    game.print("BlinkerBoy")
    for _, player in pairs(game.players) do
        initialize_global(player)
    end
end)

script.on_configuration_changed(function(config_changed_data)
    if config_changed_data.mod_changes["better_placer"] then
        for _, player in pairs(game.players) do
            local player_global = global.players[player.index]
            if player_global.elements.main_frame ~= nil then toggle_interface(player) end
        end
    end
end)


script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    initialize_global(player)
end)

script.on_event(defines.events.on_player_removed, function(event)
    global.players[event.player_index] = nil
end)

-- Moved to control.lua

-- script.on_event("toggle-placing", function(event)
--     game.print("Deactivated")
--     local player = game.get_player(event.player_index)
--     toggle_interface(player)
-- end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.element and event.element.name == "main_frame" then
        local player = game.get_player(event.player_index)
        toggle_interface(player)
    end
end)


script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "controls_toggle" then
        local player_global = global.players[event.player_index]
        player_global.controls_active = not player_global.controls_active

        local control_toggle = event.element
    -- elseif event.element.tags.action == "select_button" then
    --     local player = game.get_player(event.player_index)
    --     local player_global = global.players[player.index]

    --     local clicked_item_name = event.element.tags.item_name
    --     player_global.selected_item = clicked_item_name

    --     build_sprite_buttons(player)
    end
end)


script.on_event(defines.events.on_gui_value_changed, function(event)
    if event.element.name == "controls_slider_gap" then
        local player = game.get_player(event.player_index)
        local player_global = global.players[player.index]

        local slider_value = event.element.slider_value
        player_global.max_gap = slider_value
        player_global.elements.controls_textfield_gap.text = tostring(slider_value)

        build_sprite_buttons(player)
    elseif event.element.name == "controls_slider_place" then
        local player = game.get_player(event.player_index)
        local player_global = global.players[player.index]

        local slider_value = event.element.slider_value
        player_global.max_place = slider_value

        player_global.elements.controls_textfield_place.text = tostring(slider_value)

        build_sprite_buttons(player)
    end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
    if event.element.name == "controls_textfield_gap" then
        local player = game.get_player(event.player_index)
        local player_global = global.players[player.index]

        local textfield_value = tonumber(event.element.text) or 0
        local capped_button_count = math.min(textfield_value, 6)
        player_global.max_gap = capped_button_count

        player_global.elements.controls_slider_gap.slider_value = capped_button_count

        build_sprite_buttons(player)
    elseif event.element.name == "controls_textfield_place" then
        local player = game.get_player(event.player_index)
        local player_global = global.players[player.index]

        local textfield_value = tonumber(event.element.text) or 0
        local capped_button_count = math.min(textfield_value, 6)
        player_global.max_place = capped_button_count

        player_global.elements.controls_slider_place.slider_value = capped_button_count

        build_sprite_buttons(player)
    end
end)

-- script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
--     local player = game.get_player(event.player_index)
--     local player_global = global.players[player.index]
--     if player_global.is_enabled then 
--         build_sprite_buttons(player)
--     end
-- end)






-- Main Section
-- Logic section

-- player.insert{name=event.created_entity.name, count=1}
-- event.created_entity.mine{}
script.on_event(defines.events.on_built_entity,
function(event)
    local player = game.get_player(event.player_index)
    local player_global = global.players[player.index]
    if player_global.is_enabled and moving then
        if placed < player_global.max_place then
            placed = placed + 1

        else
            gapped = gapped + 1
            player.insert{name=event.created_entity.name, count=1}
            event.created_entity.mine{}
        end
        if placed == player_global.max_place and gapped == player_global.max_gap then
            placed = 0
            gapped = 0
        end
        -- game.print("placed: " .. tostring(placed))
        -- game.print("gapped: " .. tostring(gapped))
    end
end
)
script.on_event(defines.events.on_pre_build,
function(e)
    moving = e.created_by_moving
end
)
script.on_event("toggle-placing", function(event)
    local player = game.get_player(event.player_index)
    local player_global = global.players[player.index]
    toggle_interface(player)
end)

-- script.on_event("gap-plus", function(event)
--     player_global.max_gap = player_global.max_gap + 1
-- end)

-- script.on_event("gap-minus", function(event)
--     player_global.max_gap = player_global.max_gap - 1
--     if player_global.max_gap < 1 then
--         game.print("disable the placer or increase the gap. gap was reset o one(1).")
--         player_global.max_gap = 1
--     end
-- end)

-- script.on_event("place-plus", function(event)
--     player_global.max_place = player_global.max_place + 1
-- end)

-- script.on_event("place-minus", function(event)
--     player_global.max_place = player_global.max_place - 1
--     if player_global.max_place < 1 then
--         game.print("disable the placer or increase the place. place was reset o one(1).")
--         player_global.max_place = 1
--     end
-- end)

script.on_event("reset-placing", function(event)
    placed = 1
    gapped = 0
end)