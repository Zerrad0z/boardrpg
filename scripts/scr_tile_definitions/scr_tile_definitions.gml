// ============================================
// SCRIPT: scr_tile_definitions
// ============================================
// TILE TYPE ENUMS - Define all tile types
enum TILE {
    EMPTY,      // Empty tile (player can place)
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
    DUNGEON     // D - Dungeon
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