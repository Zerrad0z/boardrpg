// ============================================
// obj_tile_interaction_window - STEP EVENT
// ============================================

// Fade in animation
if (fade_in_alpha < 1) {
    fade_in_alpha += fade_in_speed;
    fade_in_alpha = min(fade_in_alpha, 1);
}

// Check if mouse is hovering over button
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

button_hover = (mx >= button_x && mx <= button_x + button_width &&
                my >= button_y && my <= button_y + button_height);

// Handle button click
if (button_hover && mouse_check_button_pressed(mb_left)) {
    hide_tile_interaction();
}

// Alternative: Press SPACE or ENTER to continue
if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) {
    hide_tile_interaction();
}