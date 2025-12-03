// ============================================
// obj_board_manager - STEP EVENT
// ============================================

// Generate board when space is pressed
if (keyboard_check_pressed(vk_space)) {
    generate_board();
}

// Change level with arrow keys
if (keyboard_check_pressed(vk_up)) {
    current_level++;
    show_debug_message("Level increased to: " + string(current_level));
}

if (keyboard_check_pressed(vk_down)) {
    current_level = max(1, current_level - 1);
    show_debug_message("Level decreased to: " + string(current_level));
}

// Reset inventory with R key
if (keyboard_check_pressed(ord("R"))) {
    initialize_inventory();
}

// Recalculate path when P is pressed (for testing)
if (keyboard_check_pressed(ord("P"))) {
    find_path();
}

// ============================================
// DRAG & DROP LOGIC
// ============================================

// Start dragging from inventory
if (mouse_check_button_pressed(mb_left) && dragging_tile == noone) {
    var slot = get_inventory_slot_from_mouse();
    
    if (slot != -1) {
        var tile_at_slot = inventory[| slot];
        // Only drag if slot has a tile (not empty)
        if (tile_at_slot != TILE.EMPTY && is_hand_tile(tile_at_slot)) {
            dragging_tile = tile_at_slot;
            dragging_from_inventory = true;
            dragging_from_inventory_slot = slot;
            show_debug_message("Picked up " + get_tile_letter(dragging_tile) + " from inventory slot " + string(slot));
        }
    } else {
        // Check if clicking on board tile
        var pos = get_board_position_from_mouse();
        if (pos != undefined) {
            var grid_x = pos[0];
            var grid_y = pos[1];
            var tile_at_pos = board[grid_x][grid_y];
            
            // Can only pick up player-placed hand tiles
            if (board_player_placed[grid_x][grid_y] && is_hand_tile(tile_at_pos)) {
                dragging_tile = tile_at_pos;
                dragging_from_inventory = false;
                dragging_from_board_x = grid_x;
                dragging_from_board_y = grid_y;
                show_debug_message("Picked up " + get_tile_letter(dragging_tile) + " from board");
            }
        }
    }
}

// Update hover position
hover_board_x = -1;
hover_board_y = -1;
if (dragging_tile != noone) {
    var pos = get_board_position_from_mouse();
    if (pos != undefined) {
        hover_board_x = pos[0];
        hover_board_y = pos[1];
    }
}

// Drop tile
if (mouse_check_button_released(mb_left) && dragging_tile != noone) {
    var dropped = false;
    var recalculate_path = false;
    
    // Try dropping on inventory slot
    var inv_slot = get_inventory_slot_from_mouse();
    if (inv_slot != -1) {
        var target_tile = inventory[| inv_slot];
        
        // Dropping on empty inventory slot
        if (target_tile == TILE.EMPTY) {
            if (dragging_from_inventory && dragging_from_inventory_slot != -1) {
                // Move within inventory
                inventory[| inv_slot] = dragging_tile;
                inventory[| dragging_from_inventory_slot] = TILE.EMPTY;
                show_debug_message("Moved tile to empty inventory slot " + string(inv_slot));
            } else if (!dragging_from_inventory) {
                // Move from board to empty inventory slot
                inventory[| inv_slot] = dragging_tile;
                board[dragging_from_board_x][dragging_from_board_y] = TILE.EMPTY;
                board_player_placed[dragging_from_board_x][dragging_from_board_y] = false;
                show_debug_message("Moved board tile to empty inventory slot " + string(inv_slot));
                recalculate_path = true;
            }
            dropped = true;
        }
        // Dropping on occupied inventory slot - swap
        else if (is_hand_tile(target_tile)) {
            if (dragging_from_inventory && dragging_from_inventory_slot != -1) {
                // Swap within inventory
                inventory[| inv_slot] = dragging_tile;
                inventory[| dragging_from_inventory_slot] = target_tile;
                show_debug_message("Swapped inventory slots " + string(dragging_from_inventory_slot) + " and " + string(inv_slot));
            } else if (!dragging_from_inventory) {
                // Swap board tile with inventory tile
                inventory[| inv_slot] = dragging_tile;
                board[dragging_from_board_x][dragging_from_board_y] = target_tile;
                board_player_placed[dragging_from_board_x][dragging_from_board_y] = true;
                show_debug_message("Swapped board tile with inventory slot " + string(inv_slot));
                recalculate_path = true;
            }
            dropped = true;
        }
    }
    
    // Try dropping on board
    if (!dropped) {
        var pos = get_board_position_from_mouse();
        if (pos != undefined) {
            var grid_x = pos[0];
            var grid_y = pos[1];
            
            if (can_place_tile_at(grid_x, grid_y)) {
                var tile_at_target = board[grid_x][grid_y];
                
                // If swapping with another player-placed tile
                if (is_hand_tile(tile_at_target) && board_player_placed[grid_x][grid_y]) {
                    if (dragging_from_inventory && dragging_from_inventory_slot != -1) {
                        // Swap: board tile goes to inventory slot, dragged tile goes to board
                        inventory[| dragging_from_inventory_slot] = tile_at_target;
                        board[grid_x][grid_y] = dragging_tile;
                        show_debug_message("Swapped inventory tile with board tile at (" + string(grid_x) + "," + string(grid_y) + ")");
                    } else if (!dragging_from_inventory) {
                        // Swap two board tiles
                        board[dragging_from_board_x][dragging_from_board_y] = tile_at_target;
                        board_player_placed[dragging_from_board_x][dragging_from_board_y] = true;
                        board[grid_x][grid_y] = dragging_tile;
                        board_player_placed[grid_x][grid_y] = true;
                        show_debug_message("Swapped board tiles");
                    }
                } else {
                    // Placing on empty tile
                    if (dragging_from_inventory && dragging_from_inventory_slot != -1) {
                        // Move from inventory to board (leave inventory slot empty)
                        inventory[| dragging_from_inventory_slot] = TILE.EMPTY;
                    } else if (!dragging_from_inventory) {
                        // Clear the origin board position
                        board[dragging_from_board_x][dragging_from_board_y] = TILE.EMPTY;
                        board_player_placed[dragging_from_board_x][dragging_from_board_y] = false;
                    }
                    board[grid_x][grid_y] = dragging_tile;
                    board_player_placed[grid_x][grid_y] = true;
                    show_debug_message("Placed " + get_tile_letter(dragging_tile) + " at (" + string(grid_x) + "," + string(grid_y) + ")");
                }
                dropped = true;
                recalculate_path = true;
            }
        }
    }
    
    // If not dropped anywhere valid, return to original position
    if (!dropped) {
        if (dragging_from_inventory && dragging_from_inventory_slot != -1) {
            // Already in inventory, do nothing (tile stays in original slot)
            show_debug_message("Returned tile to inventory");
        } else if (!dragging_from_inventory) {
            // Return to board
            board[dragging_from_board_x][dragging_from_board_y] = dragging_tile;
            board_player_placed[dragging_from_board_x][dragging_from_board_y] = true;
            show_debug_message("Returned tile to board");
        }
    }
    
    // Recalculate path if board changed
    if (recalculate_path) {
        find_path();
    }
    
    // Reset drag state
    dragging_tile= noone;
dragging_from_inventory = false;
dragging_from_inventory_slot = -1;
dragging_from_board_x = -1;
dragging_from_board_y = -1;
}
