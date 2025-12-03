// ============================================
// obj_board_manager - CREATE EVENT
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

// Inventory system
inventory = ds_list_create();
dragging_tile = noone;
dragging_from_inventory = false;
dragging_from_inventory_slot = -1;
dragging_from_board_x = -1;
dragging_from_board_y = -1;
hover_board_x = -1;
hover_board_y = -1;

// Initialize inventory with random hand tiles and empty slots
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
    
    show_debug_message("Inventory initialized with 6 tiles and 4 empty slots");
}

// ============================================
// HELPER FUNCTIONS
// ============================================

/// @function is_static_tile
/// @description Check if a tile is a static (non-hand) tile
function is_static_tile(tile_type) {
    return (tile_type == TILE.BOSS || 
            tile_type == TILE.MERCHANT || 
            tile_type == TILE.BLACKSMITH || 
            tile_type == TILE.SHRINE || 
            tile_type == TILE.ROCK || 
            tile_type == TILE.RIVER || 
            tile_type == TILE.GRAVEYARD);
}

/// @function is_hand_tile
/// @description Check if a tile is a hand tile (player can place)
function is_hand_tile(tile_type) {
    return (tile_type == TILE.FOREST || 
            tile_type == TILE.MOUNTAIN || 
            tile_type == TILE.SWAMP || 
            tile_type == TILE.DUNGEON);
}

/// @function get_tile_letter
/// @description Returns the letter representation of a tile type
function get_tile_letter(tile_type) {
    switch(tile_type) {
        case TILE.EMPTY: return "";
        case TILE.BOSS: return "B";
        case TILE.MERCHANT: return "M";
        case TILE.BLACKSMITH: return "K";
        case TILE.SHRINE: return "S";
        case TILE.ROCK: return "R";
        case TILE.RIVER: return "~";
        case TILE.GRAVEYARD: return "G";
        case TILE.FOREST: return "F";
        case TILE.MOUNTAIN: return "N";
        case TILE.SWAMP: return "W";
        case TILE.DUNGEON: return "D";
        default: return "?";
    }
}

/// @function get_tile_color
/// @description Returns the color for each tile type
function get_tile_color(tile_type) {
    switch(tile_type) {
        case TILE.EMPTY: return c_white;
        case TILE.BOSS: return c_red;
        case TILE.MERCHANT: return c_yellow;
        case TILE.BLACKSMITH: return c_orange;
        case TILE.SHRINE: return c_aqua;
        case TILE.ROCK: return c_gray;
        case TILE.RIVER: return c_blue;
        case TILE.GRAVEYARD: return c_purple;
        case TILE.FOREST: return c_green;
        case TILE.MOUNTAIN: return c_dkgray;
        case TILE.SWAMP: return make_color_rgb(100, 150, 100);
        case TILE.DUNGEON: return make_color_rgb(80, 40, 20);
        default: return c_white;
    }
}

/// @function is_position_valid
/// @description Check if position is within board bounds
function is_position_valid(xx, yy) {
    return (xx >= 0 && xx < BOARD_SIZE && yy >= 0 && yy < BOARD_SIZE);
}

/// @function is_position_empty
/// @description Check if a board position is empty
function is_position_empty(xx, yy) {
    if (!is_position_valid(xx, yy)) return false;
    return board[xx][yy] == TILE.EMPTY;
}

/// @function get_distance
/// @description Calculate grid distance between two points
function get_distance(x1, y1, x2, y2) {
    return max(abs(x1 - x2), abs(y1 - y2));
}

/// @function check_min_distance
/// @description Check if position is far enough from all placed tiles
function check_min_distance(xx, yy, min_dist) {
    var size = ds_list_size(tiles_placed);
    for (var i = 0; i < size; i++) {
        var tile_pos = tiles_placed[| i];
        var dist = get_distance(xx, yy, tile_pos[0], tile_pos[1]);
        if (dist < min_dist) {
            return false;
        }
    }
    return true;
}

/// @function place_tile
/// @description Place a tile on the board at given position
function place_tile(xx, yy, tile_type) {
    board[xx][yy] = tile_type;
    ds_list_add(tiles_placed, [xx, yy]);
    show_debug_message("Placed " + get_tile_letter(tile_type) + " at (" + string(xx) + "," + string(yy) + ")");
}

/// @function find_random_empty_position
/// @description Find a random empty position respecting minimum distance
function find_random_empty_position(min_dist) {
    var attempts = 0;
    var max_attempts = 100;
    
    while (attempts < max_attempts) {
        var xx = irandom(BOARD_SIZE - 1);
        var yy = irandom(BOARD_SIZE - 1);
        
        if (is_position_empty(xx, yy) && check_min_distance(xx, yy, min_dist)) {
            return [xx, yy];
        }
        attempts++;
    }
    
    // Fallback: find any empty position
    for (var i = 0; i < BOARD_SIZE; i++) {
        for (var j = 0; j < BOARD_SIZE; j++) {
            if (is_position_empty(i, j)) {
                return [i, j];
            }
        }
    }
    
    return undefined;
}

/// @function is_tile_accessible
/// @description Check if a tile can be reached (not surrounded by obstacles)
function is_tile_accessible(xx, yy) {
    var accessible_neighbors = 0;
    var dirs = [[0, -1], [0, 1], [-1, 0], [1, 0]];
    
    for (var i = 0; i < array_length(dirs); i++) {
        var check_x = xx + dirs[i][0];
        var check_y = yy + dirs[i][1];
        
        if (is_position_valid(check_x, check_y)) {
            var tile = board[check_x][check_y];
            if (tile != TILE.ROCK && tile != TILE.RIVER) {
                accessible_neighbors++;
            }
        }
    }
    
    return accessible_neighbors >= 2;
}

/// @function get_spawn_chance
/// @description Get spawn chance for a tile type based on level
function get_spawn_chance(tile_type) {
    switch(tile_type) {
        case TILE.MERCHANT:
            return 80;
        case TILE.BLACKSMITH:
            if (current_level >= 2) return 50;
            return 0;
        case TILE.SHRINE:
            return 60;
        default:
            return 0;
    }
}

// ============================================
// BOARD GENERATION ALGORITHM
// ============================================

/// @function generate_board
/// @description Main board generation function
function generate_board() {
    clear_board();
    
    show_debug_message("=== Starting Board Generation (Level " + string(current_level) + ") ===");
    
    generate_boss();
    generate_unique_tiles();
    generate_obstacles();
    generate_decorative_tiles();
    
    show_debug_message("=== Board Generation Complete ===");
    show_debug_message("Empty tiles: " + string(count_empty_tiles()) + "/64");
}

/// @function clear_board
/// @description Reset the board to empty
function clear_board() {
    for (var i = 0; i < BOARD_SIZE; i++) {
        for (var j = 0; j < BOARD_SIZE; j++) {
            board[i][j] = TILE.EMPTY;
            board_player_placed[i][j] = false;
        }
    }
    ds_list_clear(tiles_placed);
}

/// @function generate_boss
function generate_boss() {
    var pos = find_random_empty_position(0);
    if (pos != undefined) {
        place_tile(pos[0], pos[1], TILE.BOSS);
    }
}

/// @function generate_unique_tiles
function generate_unique_tiles() {
    var unique_tiles = [TILE.MERCHANT, TILE.BLACKSMITH, TILE.SHRINE];
    
    for (var i = 0; i < array_length(unique_tiles); i++) {
        var tile_type = unique_tiles[i];
        var chance = get_spawn_chance(tile_type);
        
        if (random(100) < chance) {
            var pos = find_random_empty_position(MIN_DISTANCE);
            if (pos != undefined) {
                place_tile(pos[0], pos[1], tile_type);
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
        
        if (is_position_empty(xx, yy)) {
            var obstacle_type = choose(TILE.ROCK, TILE.RIVER);
            board[xx][yy] = obstacle_type;
            
            var blocked_important = false;
            var size = ds_list_size(tiles_placed);
            
            for (var i = 0; i < size; i++) {
                var tile_pos = tiles_placed[| i];
                if (!is_tile_accessible(tile_pos[0], tile_pos[1])) {
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
    var current_fill = ds_list_size(tiles_placed) + count_obstacles();
    var remaining = target_fill - current_fill;
    
    var placed = 0;
    while (placed < remaining) {
        var pos = find_random_empty_position(0);
        if (pos != undefined) {
            place_tile(pos[0], pos[1], TILE.GRAVEYARD);
            placed++;
        } else {
            break;
        }
    }
}

/// @function count_empty_tiles
function count_empty_tiles() {
    var count = 0;
    for (var i = 0; i < BOARD_SIZE; i++) {
        for (var j = 0; j < BOARD_SIZE; j++) {
            if (board[i][j] == TILE.EMPTY) count++;
        }
    }
    return count;
}

/// @function count_obstacles
function count_obstacles() {
    var count = 0;
    for (var i = 0; i < BOARD_SIZE; i++) {
        for (var j = 0; j < BOARD_SIZE; j++) {
            if (board[i][j] == TILE.ROCK || board[i][j] == TILE.RIVER) {
                count++;
            }
        }
    }
    return count;
}

// ============================================
// DRAG & DROP FUNCTIONS
// ============================================

/// @function get_board_position_from_mouse
/// @description Convert mouse position to board grid coordinates
function get_board_position_from_mouse() {
    var grid_x = floor((mouse_x - BOARD_OFFSET_X) / TILE_SIZE);
    var grid_y = floor((mouse_y - BOARD_OFFSET_Y) / TILE_SIZE);
    
    if (grid_x >= 0 && grid_x < BOARD_SIZE && grid_y >= 0 && grid_y < BOARD_SIZE) {
        return [grid_x, grid_y];
    }
    return undefined;
}

/// @function get_inventory_slot_from_mouse
/// @description Get which inventory slot is under mouse (including empty slots)
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
/// @description Check if a tile can be placed at board position
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

// Initialize inventory on create
initialize_inventory();