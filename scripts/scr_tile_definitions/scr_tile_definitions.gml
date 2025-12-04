// ============================================
// SCRIPT: scr_tile_definitions
// ============================================
// TILE TYPE ENUMS - Define all tile types
enum TILE {
    EMPTY,      // Empty tile (player can place)
    START,      // START - Player starting position (white)
    BOSS,       // B - Boss (1 per board)
    MERCHANT,   // M - Merchant (0-1 per board)
    BLACKSMITH, // K - Blacksmith (0-1 per board)
    SHRINE,     // S - Shrine (0-1 per board)
    ROCK,       // R - Rock obstacle
    RIVER,      // ~ - River obstacle
    GRAVEYARD,  // G - Graveyard
    // HAND TILES (player can place)
    FOREST,     // F - Forest
    MOUNTAIN,   // N - Mountain
    SWAMP,      // W - Swamp
    DUNGEON,    // D - Dungeon
    // CRAFTED TILES (Tier 2)
    THICKET,    // T - Thicket (Forest + Forest)
    PEAK,       // P - Peak (Mountain + Mountain)
    // CRAFTED TILES (Tier 3)
    DRAGON_LAIR // L - Dragon Lair (Peak + Peak)
}

// BOARD CONFIGURATION CONSTANTS
#macro BOARD_SIZE 8
#macro TILE_SIZE 64
#macro BOARD_OFFSET_X 100
#macro BOARD_OFFSET_Y 100

#macro FILL_PERCENTAGE 0.30
#macro OBSTACLE_PERCENTAGE 0.15
#macro MIN_DISTANCE 2

// INVENTORY CONFIGURATION
#macro INVENTORY_OFFSET_X 700
#macro INVENTORY_OFFSET_Y 100
#macro INVENTORY_TILE_SIZE 60
#macro INVENTORY_PADDING 10
#macro MAX_INVENTORY 10
#macro INVENTORY_COLS 5
#macro INVENTORY_ROWS 2

// CRAFTING CONFIGURATION
#macro CRAFTING_OFFSET_X 710
#macro CRAFTING_OFFSET_Y 360  // Moved down (was 260, now +30 pixels ≈ 1.5cm on most screens)
#macro CRAFTING_SLOT_SIZE 70
#macro CRAFTING_SLOT_PADDING 20

// ============================================
// HELPER FUNCTIONS
// ============================================

/// @function is_static_tile
/// @description Check if a tile is a static (non-hand) tile
function is_static_tile(tile_type) {
    return (tile_type == TILE.START ||
            tile_type == TILE.BOSS || 
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
            tile_type == TILE.DUNGEON ||
            tile_type == TILE.THICKET ||
            tile_type == TILE.PEAK ||
            tile_type == TILE.DRAGON_LAIR);
}

/// @function is_craftable_tile
/// @description Check if a tile can be used in crafting
function is_craftable_tile(tile_type) {
    return (tile_type == TILE.FOREST || 
            tile_type == TILE.MOUNTAIN || 
            tile_type == TILE.PEAK);
}

/// @function is_obstacle
/// @description Check if a tile blocks pathfinding
function is_obstacle(tile_type) {
    return (tile_type == TILE.ROCK || tile_type == TILE.RIVER);
}

/// @function get_tile_letter
/// @description Returns the letter representation of a tile type
function get_tile_letter(tile_type) {
    switch(tile_type) {
        case TILE.EMPTY: return "";
        case TILE.START: return "START";
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
        case TILE.THICKET: return "T";
        case TILE.PEAK: return "P";
        case TILE.DRAGON_LAIR: return "L";
        default: return "?";
    }
}

/// @function get_tile_color
/// @description Returns the color for each tile type
function get_tile_color(tile_type) {
    switch(tile_type) {
        case TILE.EMPTY: return c_white;
        case TILE.START: return c_white;
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
        case TILE.THICKET: return make_color_rgb(0, 100, 0); // Dark green
        case TILE.PEAK: return make_color_rgb(60, 60, 60); // Darker gray
        case TILE.DRAGON_LAIR: return make_color_rgb(139, 0, 0); // Dark red
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
function is_position_empty(xx, yy, board_ref) {
    if (!is_position_valid(xx, yy)) return false;
    return board_ref[xx][yy] == TILE.EMPTY;
}

/// @function get_distance
/// @description Calculate grid distance between two points
function get_distance(x1, y1, x2, y2) {
    return max(abs(x1 - x2), abs(y1 - y2));
}

/// @function check_min_distance
/// @description Check if position is far enough from all placed tiles
function check_min_distance(xx, yy, min_dist, tiles_placed_ref) {
    var size = ds_list_size(tiles_placed_ref);
    for (var i = 0; i < size; i++) {
        var tile_pos = tiles_placed_ref[| i];
        var dist = get_distance(xx, yy, tile_pos[0], tile_pos[1]);
        if (dist < min_dist) {
            return false;
        }
    }
    return true;
}

/// @function place_tile
/// @description Place a tile on the board at given position
function place_tile(xx, yy, tile_type, board_ref, tiles_placed_ref) {
    board_ref[xx][yy] = tile_type;
    ds_list_add(tiles_placed_ref, [xx, yy]);
    show_debug_message("Placed " + get_tile_letter(tile_type) + " at (" + string(xx) + "," + string(yy) + ")");
}

/// @function find_random_empty_position
/// @description Find a random empty position respecting minimum distance
function find_random_empty_position(min_dist, board_ref, tiles_placed_ref) {
    var attempts = 0;
    var max_attempts = 100;
    
    while (attempts < max_attempts) {
        var xx = irandom(BOARD_SIZE - 1);
        var yy = irandom(BOARD_SIZE - 1);
        
        if (is_position_empty(xx, yy, board_ref) && check_min_distance(xx, yy, min_dist, tiles_placed_ref)) {
            return [xx, yy];
        }
        attempts++;
    }
    
    // Fallback: find any empty position
    for (var i = 0; i < BOARD_SIZE; i++) {
        for (var j = 0; j < BOARD_SIZE; j++) {
            if (is_position_empty(i, j, board_ref)) {
                return [i, j];
            }
        }
    }
    
    return undefined;
}

/// @function is_tile_accessible
/// @description Check if a tile can be reached (not surrounded by obstacles)
function is_tile_accessible(xx, yy, board_ref) {
    var accessible_neighbors = 0;
    var dirs = [[0, -1], [0, 1], [-1, 0], [1, 0]];
    
    for (var i = 0; i < array_length(dirs); i++) {
        var check_x = xx + dirs[i][0];
        var check_y = yy + dirs[i][1];
        
        if (is_position_valid(check_x, check_y)) {
            var tile = board_ref[check_x][check_y];
            if (!is_obstacle(tile)) {
                accessible_neighbors++;
            }
        }
    }
    
    return accessible_neighbors >= 2;
}

/// @function get_spawn_chance
/// @description Get spawn chance for a tile type based on level
function get_spawn_chance(tile_type, level) {
    switch(tile_type) {
        case TILE.MERCHANT:
            return 80;
        case TILE.BLACKSMITH:
            if (level >= 2) return 50;
            return 0;
        case TILE.SHRINE:
            return 60;
        default:
            return 0;
    }
}

/// @function count_empty_tiles
function count_empty_tiles(board_ref) {
    var count = 0;
    for (var i = 0; i < BOARD_SIZE; i++) {
        for (var j = 0; j < BOARD_SIZE; j++) {
            if (board_ref[i][j] == TILE.EMPTY) count++;
        }
    }
    return count;
}

/// @function count_obstacles
function count_obstacles(board_ref) {
    var count = 0;
    for (var i = 0; i < BOARD_SIZE; i++) {
        for (var j = 0; j < BOARD_SIZE; j++) {
            if (is_obstacle(board_ref[i][j])) {
                count++;
            }
        }
    }
    return count;
}

// ============================================
// CRAFTING SYSTEM FUNCTIONS
// ============================================

/// @function get_craft_recipe
/// @description Get the result of combining two tiles
/// @param tile1 - First tile type
/// @param tile2 - Second tile type
/// @return Result tile or TILE.EMPTY if no recipe exists
function get_craft_recipe(tile1, tile2) {
    // Recipe 1: Forest + Forest = Thicket
    if ((tile1 == TILE.FOREST && tile2 == TILE.FOREST)) {
        return TILE.THICKET;
    }
    
    // Recipe 2: Mountain + Mountain = Peak
    if ((tile1 == TILE.MOUNTAIN && tile2 == TILE.MOUNTAIN)) {
        return TILE.PEAK;
    }
    
    // Recipe 3: Peak + Peak = Dragon Lair
    if ((tile1 == TILE.PEAK && tile2 == TILE.PEAK)) {
        return TILE.DRAGON_LAIR;
    }
    
    // No valid recipe
    return TILE.EMPTY;
}

/// @function can_craft
/// @description Check if two tiles can be crafted together
/// @param tile1 - First tile type
/// @param tile2 - Second tile type
/// @return true if valid recipe exists
function can_craft(tile1, tile2) {
    return get_craft_recipe(tile1, tile2) != TILE.EMPTY;
}