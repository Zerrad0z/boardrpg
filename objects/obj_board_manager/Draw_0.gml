// ============================================
// obj_board_manager - DRAW EVENT
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
draw_text(BOARD_OFFSET_X, BOARD_OFFSET_Y - 80, "Level: " + string(current_level));
draw_text(BOARD_OFFSET_X, BOARD_OFFSET_Y - 60, "Empty Tiles: " + string(count_empty_tiles(board)) + "/64");
draw_text(BOARD_OFFSET_X, BOARD_OFFSET_Y - 40, "SPACE: Generate Board | R: Reset Inventory");
draw_text(BOARD_OFFSET_X, BOARD_OFFSET_Y - 20, "Path Status: " + (has_valid_path ? "CONNECTED!" : "NOT CONNECTED"));

// Draw path info if exists
if (has_valid_path) {
    draw_set_color(c_lime);
    draw_text(BOARD_OFFSET_X + 300, BOARD_OFFSET_Y - 20, "Path Length: " + string(ds_list_size(valid_path)) + " tiles");
}