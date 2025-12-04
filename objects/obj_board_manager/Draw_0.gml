// ============================================
// obj_board_manager - COMPLETE DRAW EVENT
// (Updated with Crafting UI)
// ============================================

// Draw the board grid with tiles
for (var i = 0; i < BOARD_SIZE; i++) {
    for (var j = 0; j < BOARD_SIZE; j++) {
        var draw_x = BOARD_OFFSET_X + i * TILE_SIZE;
        var draw_y = BOARD_OFFSET_Y + j * TILE_SIZE;
        var tile_type = board[i][j];
        
        // Check if tile is on the path
        var on_path = false;
        if (has_valid_path) {
            for (var p = 0; p < ds_list_size(valid_path); p++) {
                var path_pos = valid_path[| p];
                if (path_pos[0] == i && path_pos[1] == j) {
                    on_path = true;
                    break;
                }
            }
        }
        
        // Highlight if hovering with dragged tile
        var is_hover = (dragging_tile != noone && hover_board_x == i && hover_board_y == j);
        var can_place = is_hover && can_place_tile_at(i, j);
        
        // Draw tile background
        if (is_hover) {
            draw_set_color(can_place ? c_lime : c_red);
            draw_set_alpha(0.5);
        } else if (on_path) {
            // Highlight path tiles with glow effect
            draw_set_color(c_yellow);
            draw_set_alpha(0.6);
        } else {
            draw_set_color(get_tile_color(tile_type));
            draw_set_alpha(1);
        }
        
        draw_rectangle(draw_x, draw_y, draw_x + TILE_SIZE - 2, draw_y + TILE_SIZE - 2, false);
        draw_set_alpha(1);
        
        // Extra glow for path tiles
        if (on_path && !is_hover) {
            draw_set_color(c_yellow);
            draw_set_alpha(0.3);
            draw_rectangle(draw_x + 4, draw_y + 4, draw_x + TILE_SIZE - 6, draw_y + TILE_SIZE - 6, false);
            draw_set_alpha(1);
        }
        
        // Highlight player-placed tiles with a border
        if (board_player_placed[i][j]) {
            draw_set_color(c_lime);
            draw_rectangle(draw_x + 2, draw_y + 2, draw_x + TILE_SIZE - 4, draw_y + TILE_SIZE - 4, true);
            draw_rectangle(draw_x + 3, draw_y + 3, draw_x + TILE_SIZE - 5, draw_y + TILE_SIZE - 5, true);
        }
        
        // Draw grid lines
        draw_set_color(c_black);
        draw_rectangle(draw_x, draw_y, draw_x + TILE_SIZE - 2, draw_y + TILE_SIZE - 2, true);
        
        // Draw tile letter
        if (tile_type != TILE.EMPTY) {
            draw_set_color(c_black);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            var letter = get_tile_letter(tile_type);
            draw_text(draw_x + TILE_SIZE / 2, draw_y + TILE_SIZE / 2, letter);
        }
    }
}

// Draw inventory panel
var inv_width = INVENTORY_COLS * (INVENTORY_TILE_SIZE + INVENTORY_PADDING) + 10;
var inv_height = INVENTORY_ROWS * (INVENTORY_TILE_SIZE + INVENTORY_PADDING) + 50;

draw_set_color(c_dkgray);
draw_rectangle(INVENTORY_OFFSET_X - 10, INVENTORY_OFFSET_Y - 40, 
               INVENTORY_OFFSET_X + inv_width, 
               INVENTORY_OFFSET_Y + inv_height, false);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(INVENTORY_OFFSET_X, INVENTORY_OFFSET_Y - 30, "INVENTORY (" + string(ds_list_size(inventory)) + "/" + string(MAX_INVENTORY) + ")");

// Draw inventory tiles in grid
for (var i = 0; i < MAX_INVENTORY; i++) {
    var tile_type = TILE.EMPTY;
    if (i < ds_list_size(inventory)) {
        tile_type = inventory[| i];
    }
    
    var col = i mod INVENTORY_COLS;
    var row = i div INVENTORY_COLS;
    var slot_x = INVENTORY_OFFSET_X + col * (INVENTORY_TILE_SIZE + INVENTORY_PADDING);
    var slot_y = INVENTORY_OFFSET_Y + row * (INVENTORY_TILE_SIZE + INVENTORY_PADDING);
    
    // Skip if this is the slot being dragged from
    if (dragging_from_inventory && dragging_from_inventory_slot == i && tile_type != TILE.EMPTY) {
        // Draw empty slot placeholder
        draw_set_color(c_gray);
        draw_set_alpha(0.3);
        draw_rectangle(slot_x, slot_y, slot_x + INVENTORY_TILE_SIZE, slot_y + INVENTORY_TILE_SIZE, false);
        draw_set_alpha(1);
        draw_set_color(c_black);
        draw_rectangle(slot_x, slot_y, slot_x + INVENTORY_TILE_SIZE, slot_y + INVENTORY_TILE_SIZE, true);
        continue;
    }
    
    // Draw slot background
    if (tile_type == TILE.EMPTY) {
        draw_set_color(c_gray);
        draw_set_alpha(0.3);
    } else {
        draw_set_color(get_tile_color(tile_type));
        draw_set_alpha(1);
    }
    draw_rectangle(slot_x, slot_y, slot_x + INVENTORY_TILE_SIZE, slot_y + INVENTORY_TILE_SIZE, false);
    draw_set_alpha(1);
    
    // Draw slot border
    draw_set_color(c_black);
    draw_rectangle(slot_x, slot_y, slot_x + INVENTORY_TILE_SIZE, slot_y + INVENTORY_TILE_SIZE, true);
    
    // Draw tile letter
    if (tile_type != TILE.EMPTY) {
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(slot_x + INVENTORY_TILE_SIZE / 2, slot_y + INVENTORY_TILE_SIZE / 2, get_tile_letter(tile_type));
    }
}

// ============================================
// DRAW CRAFTING PANEL
// ============================================

var craft_panel_width = 250;
var craft_panel_height = 280;

// Draw crafting panel background
draw_set_color(c_dkgray);
draw_rectangle(CRAFTING_OFFSET_X - 10, CRAFTING_OFFSET_Y - 10,
               CRAFTING_OFFSET_X + craft_panel_width,
               CRAFTING_OFFSET_Y + craft_panel_height, false);

// Draw crafting panel border
draw_set_color(c_white);
draw_rectangle(CRAFTING_OFFSET_X - 10, CRAFTING_OFFSET_Y - 10,
               CRAFTING_OFFSET_X + craft_panel_width,
               CRAFTING_OFFSET_Y + craft_panel_height, true);

// Draw title
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(CRAFTING_OFFSET_X, CRAFTING_OFFSET_Y, "TILE CRAFTING");

// Calculate slot positions
var slot1_x = CRAFTING_OFFSET_X;
var slot1_y = CRAFTING_OFFSET_Y + 40;

var plus_x = CRAFTING_OFFSET_X + CRAFTING_SLOT_SIZE + 10;
var plus_y = CRAFTING_OFFSET_Y + 40 + (CRAFTING_SLOT_SIZE / 2);

var slot2_x = CRAFTING_OFFSET_X + CRAFTING_SLOT_SIZE + CRAFTING_SLOT_PADDING + 30;
var slot2_y = CRAFTING_OFFSET_Y + 40;

var button_x = CRAFTING_OFFSET_X + 50;
var button_y = CRAFTING_OFFSET_Y + 120;
var button_width = 150;
var button_height = 40;

var result_x = CRAFTING_OFFSET_X + (CRAFTING_SLOT_SIZE + 15);
var result_y = CRAFTING_OFFSET_Y + 170;

// Update hover state
hover_crafting_slot = 0;
if (dragging_tile != noone) {
    if (mouse_in_crafting_slot_1()) hover_crafting_slot = 1;
    else if (mouse_in_crafting_slot_2()) hover_crafting_slot = 2;
}

// Draw Crafting Slot 1
if (crafting_slot_1 == TILE.EMPTY) {
    // Empty slot
    draw_set_color(c_gray);
    draw_set_alpha(0.3);
    draw_rectangle(slot1_x, slot1_y, slot1_x + CRAFTING_SLOT_SIZE, slot1_y + CRAFTING_SLOT_SIZE, false);
    draw_set_alpha(1);
    
    // Dashed border
    draw_set_color(c_ltgray);
    for (var i = 0; i < 4; i++) {
        draw_rectangle(slot1_x + i * 2, slot1_y + i * 2,
                      slot1_x + CRAFTING_SLOT_SIZE - i * 2,
                      slot1_y + CRAFTING_SLOT_SIZE - i * 2, true);
    }
} else {
    // Has tile
    draw_set_color(get_tile_color(crafting_slot_1));
    draw_rectangle(slot1_x, slot1_y, slot1_x + CRAFTING_SLOT_SIZE, slot1_y + CRAFTING_SLOT_SIZE, false);
    
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(slot1_x + CRAFTING_SLOT_SIZE / 2, slot1_y + CRAFTING_SLOT_SIZE / 2, get_tile_letter(crafting_slot_1));
}

// Hover highlight for slot 1
if (hover_crafting_slot == 1 && is_craftable_tile(dragging_tile)) {
    draw_set_color(c_lime);
    draw_rectangle(slot1_x, slot1_y, slot1_x + CRAFTING_SLOT_SIZE, slot1_y + CRAFTING_SLOT_SIZE, true);
    draw_rectangle(slot1_x + 1, slot1_y + 1, slot1_x + CRAFTING_SLOT_SIZE - 1, slot1_y + CRAFTING_SLOT_SIZE - 1, true);
}

// Draw slot 1 border
draw_set_color(c_black);
draw_rectangle(slot1_x, slot1_y, slot1_x + CRAFTING_SLOT_SIZE, slot1_y + CRAFTING_SLOT_SIZE, true);

// Draw plus symbol
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed(plus_x, plus_y, "+", 2, 2, 0);

// Draw Crafting Slot 2
if (crafting_slot_2 == TILE.EMPTY) {
    // Empty slot
    draw_set_color(c_gray);
    draw_set_alpha(0.3);
    draw_rectangle(slot2_x, slot2_y, slot2_x + CRAFTING_SLOT_SIZE, slot2_y + CRAFTING_SLOT_SIZE, false);
    draw_set_alpha(1);
    
    // Dashed border
    draw_set_color(c_ltgray);
    for (var i = 0; i < 4; i++) {
        draw_rectangle(slot2_x + i * 2, slot2_y + i * 2,
                      slot2_x + CRAFTING_SLOT_SIZE - i * 2,
                      slot2_y + CRAFTING_SLOT_SIZE - i * 2, true);
    }
} else {
    // Has tile
    draw_set_color(get_tile_color(crafting_slot_2));
    draw_rectangle(slot2_x, slot2_y, slot2_x + CRAFTING_SLOT_SIZE, slot2_y + CRAFTING_SLOT_SIZE, false);
    
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(slot2_x + CRAFTING_SLOT_SIZE / 2, slot2_y + CRAFTING_SLOT_SIZE / 2, get_tile_letter(crafting_slot_2));
}

// Hover highlight for slot 2
if (hover_crafting_slot == 2 && is_craftable_tile(dragging_tile)) {
    draw_set_color(c_lime);
    draw_rectangle(slot2_x, slot2_y, slot2_x + CRAFTING_SLOT_SIZE, slot2_y + CRAFTING_SLOT_SIZE, true);
    draw_rectangle(slot2_x + 1, slot2_y + 1, slot2_x + CRAFTING_SLOT_SIZE - 1, slot2_y + CRAFTING_SLOT_SIZE - 1, true);
}

// Draw slot 2 border
draw_set_color(c_black);
draw_rectangle(slot2_x, slot2_y, slot2_x + CRAFTING_SLOT_SIZE, slot2_y + CRAFTING_SLOT_SIZE, true);

// Draw Combine Button
var button_enabled = (crafting_slot_1 != TILE.EMPTY && crafting_slot_2 != TILE.EMPTY && !result_slot_has_tile);
var button_hover = mouse_in_combine_button();

if (!button_enabled) {
    // Disabled button
    draw_set_color(c_gray);
    draw_set_alpha(0.5);
} else if (button_hover) {
    // Hover state
    draw_set_color(c_lime);
} else {
    // Normal enabled state
    draw_set_color(c_green);
}

draw_rectangle(button_x, button_y, button_x + button_width, button_y + button_height, false);
draw_set_alpha(1);

// Button border
draw_set_color(c_black);
draw_rectangle(button_x, button_y, button_x + button_width, button_y + button_height, true);

// Button text
draw_set_color(button_enabled ? c_white : c_dkgray);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(button_x + button_width / 2, button_y + button_height / 2, "COMBINE");

// Draw arrow pointing down
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(result_x + CRAFTING_SLOT_SIZE / 2, button_y + button_height + 5, "↓");

// Draw Result Slot
if (!result_slot_has_tile) {
    // Preview mode - show what WILL be crafted
    if (crafting_slot_1 != TILE.EMPTY && crafting_slot_2 != TILE.EMPTY) {
        var preview_result = get_craft_recipe(crafting_slot_1, crafting_slot_2);
        
        if (preview_result != TILE.EMPTY) {
            // Valid recipe - show preview
            draw_set_color(get_tile_color(preview_result));
            draw_set_alpha(0.5);
            draw_rectangle(result_x, result_y, result_x + CRAFTING_SLOT_SIZE, result_y + CRAFTING_SLOT_SIZE, false);
            draw_set_alpha(1);
            
            draw_set_color(c_white);
            draw_set_alpha(0.5);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(result_x + CRAFTING_SLOT_SIZE / 2, result_y + CRAFTING_SLOT_SIZE / 2, get_tile_letter(preview_result));
            draw_set_alpha(1);
            
            draw_set_color(c_gray);
            draw_rectangle(result_x, result_y, result_x + CRAFTING_SLOT_SIZE, result_y + CRAFTING_SLOT_SIZE, true);
        } else {
            // Invalid recipe
            draw_set_color(c_red);
            draw_set_alpha(0.3);
            draw_rectangle(result_x, result_y, result_x + CRAFTING_SLOT_SIZE, result_y + CRAFTING_SLOT_SIZE, false);
            draw_set_alpha(1);
            
            draw_set_color(c_red);
            draw_rectangle(result_x, result_y, result_x + CRAFTING_SLOT_SIZE, result_y + CRAFTING_SLOT_SIZE, true);
            
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(result_x + CRAFTING_SLOT_SIZE / 2, result_y + CRAFTING_SLOT_SIZE / 2, "?");
        }
    } else {
        // Empty result slot
        draw_set_color(c_gray);
        draw_set_alpha(0.3);
        draw_rectangle(result_x, result_y, result_x + CRAFTING_SLOT_SIZE, result_y + CRAFTING_SLOT_SIZE, false);
        draw_set_alpha(1);
        
        draw_set_color(c_ltgray);
        draw_rectangle(result_x, result_y, result_x + CRAFTING_SLOT_SIZE, result_y + CRAFTING_SLOT_SIZE, true);
    }
} else {
    // Result is ready - solid, draggable
    if (!result_slot_temp_hidden) {
        draw_set_color(get_tile_color(crafting_result));
        draw_rectangle(result_x, result_y, result_x + CRAFTING_SLOT_SIZE, result_y + CRAFTING_SLOT_SIZE, false);
        
        // Glowing border
        draw_set_color(c_lime);
        draw_rectangle(result_x, result_y, result_x + CRAFTING_SLOT_SIZE, result_y + CRAFTING_SLOT_SIZE, true);
        draw_rectangle(result_x + 1, result_y + 1, result_x + CRAFTING_SLOT_SIZE - 1, result_y + CRAFTING_SLOT_SIZE - 1, true);
        
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(result_x + CRAFTING_SLOT_SIZE / 2, result_y + CRAFTING_SLOT_SIZE / 2, get_tile_letter(crafting_result));
        
        // "Drag to use" hint
        draw_set_color(c_ltgray);
        draw_set_halign(fa_center);
        draw_text(result_x + CRAFTING_SLOT_SIZE / 2, result_y + CRAFTING_SLOT_SIZE + 10, "Drag to use");
    } else {
        // Hidden during drag
        draw_set_color(c_gray);
        draw_set_alpha(0.3);
        draw_rectangle(result_x, result_y, result_x + CRAFTING_SLOT_SIZE, result_y + CRAFTING_SLOT_SIZE, false);
        draw_set_alpha(1);
    }
}

// Draw result slot border
draw_set_color(c_black);
draw_rectangle(result_x, result_y, result_x + CRAFTING_SLOT_SIZE, result_y + CRAFTING_SLOT_SIZE, true);

// ============================================
// END OF CRAFTING UI
// ============================================

// Draw dragging tile following mouse
if (dragging_tile != noone) {
    draw_set_alpha(0.7);
    draw_set_color(get_tile_color(dragging_tile));
    draw_rectangle(mouse_x - 30, mouse_y - 30, mouse_x + 30, mouse_y + 30, false);
    
    draw_set_color(c_black);
    draw_rectangle(mouse_x - 30, mouse_y - 30, mouse_x + 30, mouse_y + 30, true);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(mouse_x, mouse_y, get_tile_letter(dragging_tile));
}

// Draw UI info
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(BOARD_OFFSET_X, BOARD_OFFSET_Y - 100, "ENTER: Start player movement");
draw_text(BOARD_OFFSET_X, BOARD_OFFSET_Y - 80, "Level: " + string(current_level));
draw_text(BOARD_OFFSET_X, BOARD_OFFSET_Y - 60, "Empty Tiles: " + string(count_empty_tiles(board)) + "/64");
draw_text(BOARD_OFFSET_X, BOARD_OFFSET_Y - 40, "SPACE: Generate Board | R: Reset Inventory");
draw_text(BOARD_OFFSET_X, BOARD_OFFSET_Y - 20, "Path Status: " + (has_valid_path ? "CONNECTED!" : "NOT CONNECTED"));

// Draw path info if exists
if (has_valid_path) {
    draw_set_color(c_lime);
    draw_text(BOARD_OFFSET_X + 300, BOARD_OFFSET_Y - 20, "Path Length: " + string(ds_list_size(valid_path)) + " tiles");
}

// Draw player marker
if (player_visible) {
    // Draw player shadow
    draw_set_color(c_black);
    draw_set_alpha(0.3);
    draw_circle(player_x + 2, player_y + 4, 12, false);
    draw_set_alpha(1);
    
    // Draw player marker (circle with outline)
    draw_set_color(c_yellow);
    draw_circle(player_x, player_y, 14, false);
    
    draw_set_color(c_orange);
    draw_circle(player_x, player_y, 14, true);
    draw_circle(player_x, player_y, 13, true);
    
    // Draw player icon (P letter)
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(player_x, player_y, "P");
    
    // Draw path progress indicator
    if (has_valid_path) {
        var progress_text = "Progress: " + string(player_current_tile + 1) + "/" + string(ds_list_size(valid_path));
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text(INVENTORY_OFFSET_X, INVENTORY_OFFSET_Y + inv_height + 20, progress_text);
        
        // Show current tile type
        if (player_current_tile < ds_list_size(valid_path)) {
            var current_pos = valid_path[| player_current_tile];
            var current_tile_type = board[current_pos[0]][current_pos[1]];
            var tile_text = "Current Tile: " + get_tile_letter(current_tile_type);
            draw_text(INVENTORY_OFFSET_X, INVENTORY_OFFSET_Y + inv_height + 40, tile_text);
        }
    }
}