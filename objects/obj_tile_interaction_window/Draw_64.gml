
// ============================================
// obj_tile_interaction_window - DRAW GUI EVENT
// ============================================

// Draw semi-transparent overlay
draw_set_alpha(fade_in_alpha * 0.7);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Only draw window if fully visible
if (fade_in_alpha > 0) {
    draw_set_alpha(fade_in_alpha);
    
    // Draw window background
    draw_set_color(c_dkgray);
    draw_rectangle(window_x, window_y, window_x + window_width, window_y + window_height, false);
    
    // Draw window border
    draw_set_color(c_white);
    draw_rectangle(window_x, window_y, window_x + window_width, window_y + window_height, true);
    draw_rectangle(window_x + 2, window_y + 2, window_x + window_width - 2, window_y + window_height - 2, true);
    
    // Draw tile icon (large letter for now)
    var icon_color = c_white;
    if (instance_exists(obj_board_manager)) {
        icon_color = get_tile_color(current_tile_type);
    }
    
    // Icon background circle
    var icon_x = window_x + window_width / 2;
    var icon_y = window_y + 80;
    var icon_radius = 40;
    
    draw_set_color(icon_color);
    draw_circle(icon_x, icon_y, icon_radius, false);
    
    draw_set_color(c_white);
    draw_circle(icon_x, icon_y, icon_radius, true);
    draw_circle(icon_x, icon_y, icon_radius - 1, true);
    
    // Draw icon letter
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(-1); // Default font
    draw_text_transformed(icon_x, icon_y, current_tile_icon, 2, 2, 0);
    
    // Draw tile title
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(window_x + window_width / 2, window_y + 140, current_tile_title);
    
    // Draw tile description
    draw_set_color(c_ltgray);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text_ext(window_x + window_width / 2, window_y + 170, current_tile_description, 20, window_width - 40);
    
    // Draw continue button
    if (button_hover) {
        draw_set_color(c_yellow);
    } else {
        draw_set_color(c_white);
    }
    draw_rectangle(button_x, button_y, button_x + button_width, button_y + button_height, false);
    
    // Button border
    draw_set_color(c_black);
    draw_rectangle(button_x, button_y, button_x + button_width, button_y + button_height, true);
    draw_rectangle(button_x + 1, button_y + 1, button_x + button_width - 1, button_y + button_height - 1, true);
    
    // Button text
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(button_x + button_width / 2, button_y + button_height / 2, "CONTINUE");
    
    // Draw hint text
    draw_set_color(c_gray);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(window_x + window_width / 2, button_y + button_height + 10, "[SPACE or ENTER to continue]");
    
    draw_set_alpha(1);
}