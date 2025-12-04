// ============================================
// obj_tile_interaction_window - CREATE EVENT
// ============================================

// Window dimensions and position
window_width = 600;
window_height = 400;
window_x = (room_width / 2) - (window_width / 2);
window_y = (room_height / 2) - (window_height / 2);

// Button dimensions and position
button_width = 200;
button_height = 50;
button_x = window_x + (window_width / 2) - (button_width / 2);
button_y = window_y + window_height - button_height - 30;

// Button state
button_hover = false;

// Animation
fade_in_alpha = 0;
fade_in_speed = 0.1;

// Get tile info from board manager
current_tile_type = TILE.EMPTY;
current_tile_title = "";
current_tile_description = "";
current_tile_icon = "";

if (instance_exists(obj_board_manager)) {
    with (obj_board_manager) {
        other.current_tile_type = interaction_current_tile;
        other.current_tile_title = get_tile_title(interaction_current_tile);
        other.current_tile_description = get_tile_description(interaction_current_tile);
        other.current_tile_icon = get_tile_icon_letter(interaction_current_tile);
    }
}

show_debug_message("Interaction window created for: " + current_tile_title);
