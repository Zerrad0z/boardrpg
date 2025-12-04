// ============================================
// obj_board_manager - COMPLETE STEP EVENT
// (Updated with Crafting System Logic)
// ============================================

// Generate board when space is pressed
if (keyboard_check_pressed(vk_space)) {
    generate_board();
    // Reset player
    player_visible = false;
    player_moving = false;
    player_current_tile = 0;
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
// PLAYER MOVEMENT SYSTEM
// ============================================

// Start player movement when Enter is pressed
if (keyboard_check_pressed(vk_enter)) {
    // Don't start if interaction window is active
    if (!interaction_window_active) {
        if (has_valid_path && ds_list_size(valid_path) > 0) {
            // Start the player at the beginning of the path
            player_visible = true;
            player_current_tile = 0;
            player_moving = false;
            player_move_progress = 0;
            
            // Set player position to START tile
            var start_tile = valid_path[| 0];
            player_x = BOARD_OFFSET_X + start_tile[0] * TILE_SIZE + TILE_SIZE / 2;
            player_y = BOARD_OFFSET_Y + start_tile[1] * TILE_SIZE + TILE_SIZE / 2;
            player_target_x = player_x;
            player_target_y = player_y;
            
            show_debug_message("Player movement started!");
            
            // Show interaction window for START tile
            var current_pos = valid_path[| player_current_tile];
            var tile_type = board[current_pos[0]][current_pos[1]];
            show_tile_interaction(tile_type, current_pos[0], current_pos[1]);
        } else {
            show_debug_message("Cannot start - no valid path exists!");
        }
    }
}

// Handle player movement along path (only if window is NOT active)
if (player_moving && player_visible && !interaction_window_active) {
    player_move_progress += player_move_speed;
    
    // Interpolate position
    player_x = lerp(player_x, player_target_x, player_move_progress);
    player_y = lerp(player_y, player_target_y, player_move_progress);
    
    // Check if reached target tile
    if (player_move_progress >= 1) {
        player_move_progress = 0;
        player_current_tile++;
        
        // Snap to exact position
        player_x = player_target_x;
        player_y = player_target_y;
        
        // Pause movement
        player_moving = false;
        
        var current_pos = valid_path[| player_current_tile];
        var tile_type = board[current_pos[0]][current_pos[1]];
        show_debug_message("Player reached tile " + string(player_current_tile) + ": " + get_tile_letter(tile_type));
        
        // Show interaction window for this tile
        show_tile_interaction(tile_type, current_pos[0], current_pos[1]);
        
        // Set next target (will move when window closes)
        if (player_current_tile < ds_list_size(valid_path) - 1) {
            var next_tile = valid_path[| player_current_tile + 1];
            player_target_x = BOARD_OFFSET_X + next_tile[0] * TILE_SIZE + TILE_SIZE / 2;
            player_target_y = BOARD_OFFSET_Y + next_tile[1] * TILE_SIZE + TILE_SIZE / 2;
        } else {
            show_debug_message("Player reached the BOSS!");
        }
    }
}

// ============================================
// CRAFTING SYSTEM LOGIC
// ============================================

// Handle Combine Button Click
if (mouse_check_button_pressed(mb_left) && !interaction_window_active) {
    if (mouse_in_combine_button()) {
        // Check if we can craft
        if (crafting_slot_1 != TILE.EMPTY && crafting_slot_2 != TILE.EMPTY && !result_slot_has_tile) {
            var recipe_result = get_craft_recipe(crafting_slot_1, crafting_slot_2);
            
            if (recipe_result != TILE.EMPTY) {
                // Valid recipe - craft it!
                crafting_result = recipe_result;
                result_slot_has_tile = true;
                
                // Clear the input slots
                crafting_slot_1 = TILE.EMPTY;
                crafting_slot_2 = TILE.EMPTY;
                
                show_debug_message("=== CRAFTED: " + get_tile_letter(crafting_result) + " ===");
            } else {
                show_debug_message("Invalid recipe!");
            }
        }
    }
}

// Right-click to return tiles from crafting slots to inventory (ALWAYS works!)
if (mouse_check_button_pressed(mb_right) && !interaction_window_active && dragging_tile == noone) {
    // Check crafting slot 1
    if (mouse_in_crafting_slot_1() && crafting_slot_1 != TILE.EMPTY) {
        // Find first empty inventory slot
        var empty_slot = get_first_empty_inventory_slot();
        
        if (empty_slot != -1) {
            // Return slot 1 to first available empty slot
            inventory[| empty_slot] = crafting_slot_1;
            show_debug_message("Returned " + get_tile_letter(crafting_slot_1) + " to inventory slot " + string(empty_slot));
        } else {
            show_debug_message("No empty inventory slots! Cannot return tile.");
        }
        
        crafting_slot_1 = TILE.EMPTY;
        crafting_slot_1_from_inventory = -1;
        
        // Update result preview based on what's left
        if (crafting_slot_2 != TILE.EMPTY) {
            crafting_result = get_craft_recipe(TILE.EMPTY, crafting_slot_2); // Will be empty since slot 1 is empty
        } else {
            crafting_result = TILE.EMPTY;
        }
        
        // Clear crafted result if it exists
        result_slot_has_tile = false;
    }
    // Check crafting slot 2
    else if (mouse_in_crafting_slot_2() && crafting_slot_2 != TILE.EMPTY) {
        // Find first empty inventory slot
        var empty_slot = get_first_empty_inventory_slot();
        
        if (empty_slot != -1) {
            // Return slot 2 to first available empty slot
            inventory[| empty_slot] = crafting_slot_2;
            show_debug_message("Returned " + get_tile_letter(crafting_slot_2) + " to inventory slot " + string(empty_slot));
        } else {
            show_debug_message("No empty inventory slots! Cannot return tile.");
        }
        
        crafting_slot_2 = TILE.EMPTY;
        crafting_slot_2_from_inventory = -1;
        
        // Update result preview based on what's left
        if (crafting_slot_1 != TILE.EMPTY) {
            crafting_result = get_craft_recipe(crafting_slot_1, TILE.EMPTY); // Will be empty since slot 2 is empty
        } else {
            crafting_result = TILE.EMPTY;
        }
        
        // Clear crafted result if it exists
        result_slot_has_tile = false;
    }
    // Check result slot
    else if (mouse_in_result_slot() && result_slot_has_tile) {
        // Find first empty inventory slot
        var empty_slot = get_first_empty_inventory_slot();
        
        if (empty_slot != -1) {
            // Return crafted tile to inventory
            inventory[| empty_slot] = crafting_result;
            show_debug_message("Returned crafted " + get_tile_letter(crafting_result) + " to inventory slot " + string(empty_slot));
            crafting_result = TILE.EMPTY;
            result_slot_has_tile = false;
        } else {
            show_debug_message("No empty inventory slots! Cannot return crafted tile.");
        }
    }
    // NEW: Check board tiles (player-placed only)
    else {
        var pos = get_board_position_from_mouse();
        if (pos != undefined) {
            var grid_x = pos[0];
            var grid_y = pos[1];
            var tile_at_pos = board[grid_x][grid_y];
            
            // Only allow returning player-placed hand tiles
            if (board_player_placed[grid_x][grid_y] && is_hand_tile(tile_at_pos)) {
                // Find first empty inventory slot
                var empty_slot = get_first_empty_inventory_slot();
                
                if (empty_slot != -1) {
                    // Return board tile to inventory
                    inventory[| empty_slot] = tile_at_pos;
                    board[grid_x][grid_y] = TILE.EMPTY;
                    board_player_placed[grid_x][grid_y] = false;
                    show_debug_message("Returned " + get_tile_letter(tile_at_pos) + " from board to inventory slot " + string(empty_slot));
                    
                    // Recalculate path since board changed
                    find_path();
                } else {
                    show_debug_message("No empty inventory slots! Cannot return tile from board.");
                }
            }
        }
    }
}

// ============================================
// DRAG & DROP LOGIC (Updated with Crafting)
// ============================================

// Only allow dragging if interaction window is NOT active
if (!interaction_window_active) {
    // Start dragging from inventory OR result slot OR crafting slots
    if (mouse_check_button_pressed(mb_left) && dragging_tile == noone) {
        // Check if clicking result slot first
        if (mouse_in_result_slot() && result_slot_has_tile) {
            dragging_tile = crafting_result;
            dragging_from_crafting_result = true;
            result_slot_temp_hidden = true;
            show_debug_message("Picked up " + get_tile_letter(dragging_tile) + " from result slot");
        }
        // NEW: Check if clicking crafting slot 1
        else if (mouse_in_crafting_slot_1() && crafting_slot_1 != TILE.EMPTY) {
            dragging_tile = crafting_slot_1;
            dragging_from_inventory = false;
            dragging_from_crafting_slot = true; // NEW FLAG!
            dragging_from_inventory_slot = -1;
            
            crafting_slot_1 = TILE.EMPTY;
            crafting_slot_1_from_inventory = -1;
            
            // Clear result preview
            if (crafting_slot_2 != TILE.EMPTY) {
                crafting_result = get_craft_recipe(TILE.EMPTY, crafting_slot_2);
            } else {
                crafting_result = TILE.EMPTY;
            }
            result_slot_has_tile = false;
            
            show_debug_message("Picked up " + get_tile_letter(dragging_tile) + " from crafting slot 1");
        }
        // NEW: Check if clicking crafting slot 2
        else if (mouse_in_crafting_slot_2() && crafting_slot_2 != TILE.EMPTY) {
            dragging_tile = crafting_slot_2;
            dragging_from_inventory = false;
            dragging_from_crafting_slot = true; // NEW FLAG!
            dragging_from_inventory_slot = -1;
            
            crafting_slot_2 = TILE.EMPTY;
            crafting_slot_2_from_inventory = -1;
            
            // Clear result preview
            if (crafting_slot_1 != TILE.EMPTY) {
                crafting_result = get_craft_recipe(crafting_slot_1, TILE.EMPTY);
            } else {
                crafting_result = TILE.EMPTY;
            }
            result_slot_has_tile = false;
            
            show_debug_message("Picked up " + get_tile_letter(dragging_tile) + " from crafting slot 2");
        }
        else {
            // Check inventory
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
        
        // NEW: Check if dropping on crafting slots (only if tile is craftable)
        if (is_craftable_tile(dragging_tile) && dragging_from_inventory) {
            if (mouse_in_crafting_slot_1() && crafting_slot_1 == TILE.EMPTY) {
                crafting_slot_1 = dragging_tile;
                crafting_slot_1_from_inventory = dragging_from_inventory_slot;
                inventory[| dragging_from_inventory_slot] = TILE.EMPTY;
                show_debug_message("Placed " + get_tile_letter(dragging_tile) + " in crafting slot 1");
                dropped = true;
                
                // Update result preview
                if (crafting_slot_2 != TILE.EMPTY && !result_slot_has_tile) {
                    crafting_result = get_craft_recipe(crafting_slot_1, crafting_slot_2);
                }
            } else if (mouse_in_crafting_slot_2() && crafting_slot_2 == TILE.EMPTY) {
                crafting_slot_2 = dragging_tile;
                crafting_slot_2_from_inventory = dragging_from_inventory_slot;
                inventory[| dragging_from_inventory_slot] = TILE.EMPTY;
                show_debug_message("Placed " + get_tile_letter(dragging_tile) + " in crafting slot 2");
                dropped = true;
                
                // Update result preview
                if (crafting_slot_1 != TILE.EMPTY && !result_slot_has_tile) {
                    crafting_result = get_craft_recipe(crafting_slot_1, crafting_slot_2);
                }
            }
        }
        
        // Try dropping on inventory slot (if not dropped on crafting)
        if (!dropped) {
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
                    } else if (!dragging_from_inventory && !dragging_from_crafting_result && !dragging_from_crafting_slot) {
                        // Move from board to empty inventory slot
                        inventory[| inv_slot] = dragging_tile;
                        board[dragging_from_board_x][dragging_from_board_y] = TILE.EMPTY;
                        board_player_placed[dragging_from_board_x][dragging_from_board_y] = false;
                        show_debug_message("Moved board tile to empty inventory slot " + string(inv_slot));
                        recalculate_path = true;
                    } else if (dragging_from_crafting_result) {
                        // Move from result slot to inventory
                        inventory[| inv_slot] = dragging_tile;
                        crafting_result = TILE.EMPTY;
                        result_slot_has_tile = false;
                        show_debug_message("Moved crafted tile to inventory slot " + string(inv_slot));
                    } else if (dragging_from_crafting_slot) {
                        // Move from crafting slot to inventory
                        inventory[| inv_slot] = dragging_tile;
                        show_debug_message("Moved tile from crafting to inventory slot " + string(inv_slot));
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
                    } else if (!dragging_from_inventory && !dragging_from_crafting_result && !dragging_from_crafting_slot) {
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
                        } else if (!dragging_from_inventory && !dragging_from_crafting_result && !dragging_from_crafting_slot) {
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
                        } else if (!dragging_from_inventory && !dragging_from_crafting_result && !dragging_from_crafting_slot) {
                            // Clear the origin board position
                            board[dragging_from_board_x][dragging_from_board_y] = TILE.EMPTY;
                            board_player_placed[dragging_from_board_x][dragging_from_board_y] = false;
                        } else if (dragging_from_crafting_result) {
                            // Placing crafted tile from result slot
                            crafting_result = TILE.EMPTY;
                            result_slot_has_tile = false;
                            show_debug_message("Placed crafted tile on board");
                        } else if (dragging_from_crafting_slot) {
                            // Placing tile from crafting slot
                            show_debug_message("Placed tile from crafting slot on board");
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
            } else if (!dragging_from_inventory && !dragging_from_crafting_result && !dragging_from_crafting_slot) {
                // Return to board
                board[dragging_from_board_x][dragging_from_board_y] = dragging_tile;
                board_player_placed[dragging_from_board_x][dragging_from_board_y] = true;
                show_debug_message("Returned tile to board");
            } else if (dragging_from_crafting_result) {
                // Return to result slot
                result_slot_temp_hidden = false;
                show_debug_message("Returned tile to result slot");
            } else if (dragging_from_crafting_slot) {
                // Can't return to crafting slot - tile is lost
                show_debug_message("Tile from crafting slot cancelled");
            }
        }
        
        // Recalculate path if board changed
        if (recalculate_path) {
            find_path();
        }
        
        // Reset drag state
        dragging_tile = noone;
        dragging_from_inventory = false;
        dragging_from_inventory_slot = -1;
        dragging_from_board_x = -1;
        dragging_from_board_y = -1;
        dragging_from_crafting_result = false;
        dragging_from_crafting_slot = false; // NEW!
        result_slot_temp_hidden = false;
    }
}