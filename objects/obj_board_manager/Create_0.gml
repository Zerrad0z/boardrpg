// ============================================
// obj_board_manager - COMPLETE CREATE EVENT
// (Updated with Crafting System)
// ============================================

// Initialize the board grid
board = array_create(BOARD_SIZE);
board_player_placed = array_create(BOARD_SIZE); // Track which tiles player placed

for (var i = 0; i < BOARD_SIZE; i++) {
    board[i] = array_create(BOARD_SIZE);
    board_player_placed[i] = array_create(BOARD_SIZE);
    for (var j = 0; j < BOARD_SIZE; j++) {
        board[i][j] = TILE.EMPTY;
        board_player_placed[i][j] = false;
    }
}

current_level = 1;
tiles_placed = ds_list_create();

// Pathfinding variables
valid_path = ds_list_create();
has_valid_path = false;
start_pos = [-1, -1];
boss_pos = [-1, -1];

// Inventory system
inventory = ds_list_create();
dragging_tile = noone;
dragging_from_inventory = false;
dragging_from_inventory_slot = -1;
dragging_from_board_x = -1;
dragging_from_board_y = -1;
hover_board_x = -1;
hover_board_y = -1;

// Player marker and movement system
player_visible = false;
player_current_tile = 0;  // Index in valid_path
player_x = 0;
player_y = 0;
player_moving = false;
player_move_speed = 0.05;  // Movement speed (0-1, where 1 is instant)
player_move_progress = 0;  // Current interpolation progress
player_target_x = 0;
player_target_y = 0;

// Interaction window system
interaction_window_active = false;      // Is the window currently showing?
interaction_current_tile = TILE.EMPTY;  // What tile type is being displayed
interaction_tile_pos = [-1, -1];        // Grid position [x, y] of the tile

// ============================================
// CRAFTING SYSTEM (NEW!)
// ============================================

// Crafting slots
crafting_slot_1 = TILE.EMPTY;               // First crafting slot
crafting_slot_2 = TILE.EMPTY;               // Second crafting slot
crafting_result = TILE.EMPTY;               // Result slot (what will/did craft)
result_slot_has_tile = false;               // Is result ready to drag out?
crafting_slot_1_from_inventory = -1;        // Which inventory slot tile 1 came from
crafting_slot_2_from_inventory = -1;        // Which inventory slot tile 2 came from

// Crafting drag state
dragging_from_crafting_result = false;      // Dragging from result slot?
result_slot_temp_hidden = false;            // Hide result during drag
hover_crafting_slot = 0;                    // 0=none, 1=slot1, 2=slot2, 3=result

// ============================================
// BOARD GENERATION FUNCTIONS
// ============================================

/// @function generate_board
function generate_board() {
    clear_board();
    
    show_debug_message("=== Starting Board Generation (Level " + string(current_level) + ") ===");
    
    generate_start();
    generate_boss();
    generate_unique_tiles();
    generate_obstacles();
    generate_decorative_tiles();
    
    // Calculate initial path
    find_path();
    
    show_debug_message("=== Board Generation Complete ===");
    show_debug_message("Empty tiles: " + string(count_empty_tiles(board)) + "/64");
}

/// @function clear_board
function clear_board() {
    for (var i = 0; i < BOARD_SIZE; i++) {
        for (var j = 0; j < BOARD_SIZE; j++) {
            board[i][j] = TILE.EMPTY;
            board_player_placed[i][j] = false;
        }
    }
    ds_list_clear(tiles_placed);
    ds_list_clear(valid_path);
    has_valid_path = false;
    start_pos = [-1, -1];
    boss_pos = [-1, -1];
}

/// @function generate_start
function generate_start() {
    var pos = find_random_empty_position(0, board, tiles_placed);
    if (pos != undefined) {
        place_tile(pos[0], pos[1], TILE.START, board, tiles_placed);
        start_pos = [pos[0], pos[1]];
    }
}

/// @function generate_boss
function generate_boss() {
    var pos = find_random_empty_position(MIN_DISTANCE, board, tiles_placed);
    if (pos != undefined) {
        place_tile(pos[0], pos[1], TILE.BOSS, board, tiles_placed);
        boss_pos = [pos[0], pos[1]];
    }
}

/// @function generate_unique_tiles
function generate_unique_tiles() {
    var unique_tiles = [TILE.MERCHANT, TILE.BLACKSMITH, TILE.SHRINE];
    
    for (var i = 0; i < array_length(unique_tiles); i++) {
        var tile_type = unique_tiles[i];
        var chance = get_spawn_chance(tile_type, current_level);
        
        if (random(100) < chance) {
            var pos = find_random_empty_position(MIN_DISTANCE, board, tiles_placed);
            if (pos != undefined) {
                place_tile(pos[0], pos[1], tile_type, board, tiles_placed);
            }
        }
    }
}

/// @function generate_obstacles
function generate_obstacles() {
    var total_tiles = BOARD_SIZE * BOARD_SIZE;
    var obstacle_count = floor(total_tiles * OBSTACLE_PERCENTAGE);
    var placed = 0;
    var attempts = 0;
    var max_attempts = obstacle_count * 5;
    
    while (placed < obstacle_count && attempts < max_attempts) {
        var xx = irandom(BOARD_SIZE - 1);
        var yy = irandom(BOARD_SIZE - 1);
        
        if (is_position_empty(xx, yy, board)) {
            var obstacle_type = choose(TILE.ROCK, TILE.RIVER);
            board[xx][yy] = obstacle_type;
            
            var blocked_important = false;
            var size = ds_list_size(tiles_placed);
            
            for (var i = 0; i < size; i++) {
                var tile_pos = tiles_placed[| i];
                if (!is_tile_accessible(tile_pos[0], tile_pos[1], board)) {
                    blocked_important = true;
                    break;
                }
            }
            
            if (blocked_important) {
                board[xx][yy] = TILE.EMPTY;
            } else {
                placed++;
            }
        }
        attempts++;
    }
}

/// @function generate_decorative_tiles
function generate_decorative_tiles() {
    var target_fill = floor(BOARD_SIZE * BOARD_SIZE * FILL_PERCENTAGE);
    var current_fill = ds_list_size(tiles_placed) + count_obstacles(board);
    var remaining = target_fill - current_fill;
    
    var placed = 0;
    while (placed < remaining) {
        var pos = find_random_empty_position(0, board, tiles_placed);
        if (pos != undefined) {
            place_tile(pos[0], pos[1], TILE.GRAVEYARD, board, tiles_placed);
            placed++;
        } else {
            break;
        }
    }
}

// ============================================
// PATHFINDING FUNCTIONS (BFS Algorithm)
// ============================================

/// @function find_path
function find_path() {
    ds_list_clear(valid_path);
    has_valid_path = false;
    
    // Check if start and boss positions are valid
    if (start_pos[0] == -1 || boss_pos[0] == -1) {
        show_debug_message("Path finding failed: Start or Boss not placed");
        return false;
    }
    
    // BFS setup
    var queue = ds_queue_create();
    var visited = ds_map_create();
    var parent = ds_map_create();
    
    // Start BFS from START position
    var start_key = string(start_pos[0]) + "," + string(start_pos[1]);
    ds_queue_enqueue(queue, start_pos);
    visited[? start_key] = true;
    parent[? start_key] = undefined;
    
    var found = false;
    var directions = [[0, -1], [0, 1], [-1, 0], [1, 0]]; // Up, Down, Left, Right
    
    // BFS loop
    while (!ds_queue_empty(queue) && !found) {
        var current = ds_queue_dequeue(queue);
        var cx = current[0];
        var cy = current[1];
        
        // Check if we reached the boss
        if (cx == boss_pos[0] && cy == boss_pos[1]) {
            found = true;
            break;
        }
        
        // Explore neighbors
        for (var i = 0; i < array_length(directions); i++) {
            var nx = cx + directions[i][0];
            var ny = cy + directions[i][1];
            
            // Check if position is valid
            if (!is_position_valid(nx, ny)) continue;
            
            var neighbor_key = string(nx) + "," + string(ny);
            
            // Skip if already visited
            if (ds_map_exists(visited, neighbor_key)) continue;
            
            var tile_at_pos = board[nx][ny];
            
            // Skip if tile is an obstacle
            if (is_obstacle(tile_at_pos)) continue;
            
            // Skip if tile is empty (no path through empty tiles)
            if (tile_at_pos == TILE.EMPTY) continue;
            
            // Valid neighbor - add to queue
            ds_queue_enqueue(queue, [nx, ny]);
            visited[? neighbor_key] = true;
            parent[? neighbor_key] = current;
        }
    }
    
    // Reconstruct path if found
    if (found) {
        var current = boss_pos;
        var path_temp = ds_list_create();
        
        while (current != undefined) {
            ds_list_add(path_temp, current);
            var current_key = string(current[0]) + "," + string(current[1]);
            current = parent[? current_key];
        }
        
        // Reverse path (it was built backwards)
        for (var i = ds_list_size(path_temp) - 1; i >= 0; i--) {
            ds_list_add(valid_path, path_temp[| i]);
        }
        
        ds_list_destroy(path_temp);
        has_valid_path = true;
        show_debug_message("Path found! Length: " + string(ds_list_size(valid_path)) + " tiles");
    } else {
        show_debug_message("No path exists from START to BOSS");
    }
    
    // Cleanup
    ds_queue_destroy(queue);
    ds_map_destroy(visited);
    ds_map_destroy(parent);
    
    return found;
}

// ============================================
// DRAG & DROP FUNCTIONS
// ============================================

/// @function get_board_position_from_mouse
function get_board_position_from_mouse() {
    var grid_x = floor((mouse_x - BOARD_OFFSET_X) / TILE_SIZE);
    var grid_y = floor((mouse_y - BOARD_OFFSET_Y) / TILE_SIZE);
    
    if (grid_x >= 0 && grid_x < BOARD_SIZE && grid_y >= 0 && grid_y < BOARD_SIZE) {
        return [grid_x, grid_y];
    }
    return undefined;
}

/// @function get_inventory_slot_from_mouse
function get_inventory_slot_from_mouse() {
    for (var i = 0; i < MAX_INVENTORY; i++) {
        var col = i mod INVENTORY_COLS;
        var row = i div INVENTORY_COLS;
        var slot_x = INVENTORY_OFFSET_X + col * (INVENTORY_TILE_SIZE + INVENTORY_PADDING);
        var slot_y = INVENTORY_OFFSET_Y + row * (INVENTORY_TILE_SIZE + INVENTORY_PADDING);
        
        if (mouse_x >= slot_x && mouse_x < slot_x + INVENTORY_TILE_SIZE &&
            mouse_y >= slot_y && mouse_y < slot_y + INVENTORY_TILE_SIZE) {
            return i;
        }
    }
    return -1;
}

/// @function can_place_tile_at
function can_place_tile_at(grid_x, grid_y) {
    if (!is_position_valid(grid_x, grid_y)) return false;
    
    var tile_at_pos = board[grid_x][grid_y];
    
    // Can place on empty tiles
    if (tile_at_pos == TILE.EMPTY) return true;
    
    // Can replace player-placed hand tiles
    if (board_player_placed[grid_x][grid_y] && is_hand_tile(tile_at_pos)) return true;
    
    // Cannot place on static tiles
    return false;
}

/// @function initialize_inventory
function initialize_inventory() {
    ds_list_clear(inventory);
    var hand_tiles = [TILE.FOREST, TILE.MOUNTAIN, TILE.SWAMP, TILE.DUNGEON];
    
    // Add 6 random tiles
    repeat(6) {
        var random_tile = hand_tiles[irandom(array_length(hand_tiles) - 1)];
        ds_list_add(inventory, random_tile);
    }
    
    // Fill remaining slots with empty
    repeat(MAX_INVENTORY - 6) {
        ds_list_add(inventory, TILE.EMPTY);
    }
    
    show_debug_message("Inventory initialized with 6 tiles and " + string(MAX_INVENTORY - 6) + " empty slots");
}

// ============================================
// CRAFTING HELPER FUNCTIONS
// ============================================

/// @function mouse_in_crafting_slot_1
function mouse_in_crafting_slot_1() {
    var slot_x = CRAFTING_OFFSET_X;
    var slot_y = CRAFTING_OFFSET_Y + 40;
    return (mouse_x >= slot_x && mouse_x < slot_x + CRAFTING_SLOT_SIZE &&
            mouse_y >= slot_y && mouse_y < slot_y + CRAFTING_SLOT_SIZE);
}

/// @function mouse_in_crafting_slot_2
function mouse_in_crafting_slot_2() {
    var slot_x = CRAFTING_OFFSET_X + CRAFTING_SLOT_SIZE + CRAFTING_SLOT_PADDING + 30;
    var slot_y = CRAFTING_OFFSET_Y + 40;
    return (mouse_x >= slot_x && mouse_x < slot_x + CRAFTING_SLOT_SIZE &&
            mouse_y >= slot_y && mouse_y < slot_y + CRAFTING_SLOT_SIZE);
}

/// @function mouse_in_result_slot
function mouse_in_result_slot() {
    var slot_x = CRAFTING_OFFSET_X + (CRAFTING_SLOT_SIZE + 15);
    var slot_y = CRAFTING_OFFSET_Y + 170;
    return (mouse_x >= slot_x && mouse_x < slot_x + CRAFTING_SLOT_SIZE &&
            mouse_y >= slot_y && mouse_y < slot_y + CRAFTING_SLOT_SIZE);
}

/// @function mouse_in_combine_button
function mouse_in_combine_button() {
    var button_width = 150;
    var button_height = 40;
    var button_x = CRAFTING_OFFSET_X + 50;
    var button_y = CRAFTING_OFFSET_Y + 120;
    return (mouse_x >= button_x && mouse_x < button_x + button_width &&
            mouse_y >= button_y && mouse_y < button_y + button_height);
}

/// @function get_first_empty_inventory_slot
function get_first_empty_inventory_slot() {
    for (var i = 0; i < ds_list_size(inventory); i++) {
        if (inventory[| i] == TILE.EMPTY) {
            return i;
        }
    }
    return -1; // No empty slots
}

/// @function clear_crafting_slots
function clear_crafting_slots() {
    crafting_slot_1 = TILE.EMPTY;
    crafting_slot_2 = TILE.EMPTY;
    crafting_result = TILE.EMPTY;
    result_slot_has_tile = false;
    crafting_slot_1_from_inventory = -1;
    crafting_slot_2_from_inventory = -1;
}

// Initialize inventory on create
initialize_inventory();