
local styles = data.raw["gui-style"].default

styles["content_frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    vertically_stretchable = "on"
}

styles["controls_flow"] = {
    type = "horizontal_flow_style",
    vertical_align = "center",
    horizontal_spacing = 16
}

styles["controls_textfield"] = {
    type = "textbox_style",
    width = 36
}

styles["deep_frame"] = {
    type = "frame_style",
    parent = "slot_button_deep_frame",
    vertically_stretchable = "on",
    horizontally_stretchable = "on",
    top_margin = 16,
    left_margin = 8,
    right_margin = 8,
    bottom_margin = 4
}

data:extend{
    {
        type = "custom-input",
        name = "gap-plus",
        key_sequence = "KP_PLUS",
        consuming = "none"
    },
    {
        type = "custom-input",
        name = "gap-minus",
        key_sequence = "KP_MINUS",
        consuming = "none"
    },
    {
        type = "custom-input",
        name = "place-plus",
        key_sequence = "SHIFT + KP_PLUS",
        consuming = "none"
    },
    {
        type = "custom-input",
        name = "place-minus",
        key_sequence = "SHIFT + KP_MINUS",
        consuming = "none"
    },
    {
        type = "custom-input",
        name = "toggle-placing",
        key_sequence = "LCTRL",
        consuming = "none"
    },
    {
        type = "custom-input",
        name = "reset-placing",
        key_sequence = "",
        consuming = "none",
        linked_game_control = "build"
    }
}