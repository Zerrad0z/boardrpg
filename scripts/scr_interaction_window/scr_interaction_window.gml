// ============================================
// SCRIPT: scr_interaction_window
// ============================================
// This script manages the tile interaction window system

/// @function show_tile_interaction
/// @description Show the interaction window for a specific tile
/// @param {TILE} tile_type - The type of tile to display
/// @param {real} grid_x - Grid X position of the tile
/// @param {real} grid_y - Grid Y position of the tile
function show_tile_interaction(tile_type, grid_x, grid_y) {
    // Store interaction data in board manager
    with (obj_board_manager) {
        interaction_window_active = true;
        interaction_current_tile = tile_type;
        interaction_tile_pos = [grid_x, grid_y];
        
        show_debug_message("=== Tile Interaction Started ===");
        show_debug_message("Tile: " + get_tile_letter(tile_type) + " at (" + string(grid_x) + "," + string(grid_y) + ")");
    }
    
    // Create the interaction window object if it doesn't exist
    if (!instance_exists(obj_tile_interaction_window)) {
        instance_create_depth(0, 0, -9999, obj_tile_interaction_window);
    }
}

/// @function hide_tile_interaction
/// @description Hide the interaction window and resume player movement
function hide_tile_interaction() {
    with (obj_board_manager) {
        interaction_window_active = false;
        interaction_current_tile = TILE.EMPTY;
        interaction_tile_pos = [-1, -1];
        
        // Resume player movement if not at the end
        if (player_visible && player_current_tile < ds_list_size(valid_path) - 1) {
            player_moving = true;
            show_debug_message("=== Tile Interaction Ended - Resuming Movement ===");
        } else if (player_visible && player_current_tile >= ds_list_size(valid_path) - 1) {
            show_debug_message("=== Tile Interaction Ended - Path Complete ===");
        }
    }
    
    // Destroy the window object
    if (instance_exists(obj_tile_interaction_window)) {
        instance_destroy(obj_tile_interaction_window);
    }
}

/// @function get_tile_title
/// @description Get the display title for a tile type
/// @param {TILE} tile_type - The tile type
/// @return {string} The title to display
function get_tile_title(tile_type) {
    switch(tile_type) {
        case TILE.START: return "STARTING POINT";
        case TILE.BOSS: return "BOSS ENCOUNTER";
        case TILE.MERCHANT: return "TRAVELING MERCHANT";
        case TILE.BLACKSMITH: return "BLACKSMITH FORGE";
        case TILE.SHRINE: return "ANCIENT SHRINE";
        case TILE.ROCK: return "ROCKY OBSTACLE";
        case TILE.RIVER: return "FLOWING RIVER";
        case TILE.GRAVEYARD: return "GRAVEYARD";
        case TILE.FOREST: return "FOREST";
        case TILE.MOUNTAIN: return "MOUNTAIN PASS";
        case TILE.SWAMP: return "MURKY SWAMP";
        case TILE.DUNGEON: return "DUNGEON ENTRANCE";
        default: return "UNKNOWN LOCATION";
    }
}

/// @function get_tile_description
/// @description Get a flavor text description for a tile type
/// @param {TILE} tile_type - The tile type
/// @return {string} The description to display
function get_tile_description(tile_type) {
    switch(tile_type) {
        case TILE.START: 
            return "Your journey begins here...";
        case TILE.BOSS: 
            return "A powerful foe awaits!";
        case TILE.MERCHANT: 
            return "Trade goods and supplies";
        case TILE.BLACKSMITH: 
            return "Upgrade your equipment";
        case TILE.SHRINE: 
            return "A place of rest and healing";
        case TILE.ROCK: 
            return "An impassable obstacle";
        case TILE.RIVER: 
            return "Water blocks your path";
        case TILE.GRAVEYARD: 
            return "The resting place of fallen heroes";
        case TILE.FOREST: 
            return "Dense trees surround you";
        case TILE.MOUNTAIN: 
            return "Steep cliffs tower above";
        case TILE.SWAMP: 
            return "Murky water slows your steps";
        case TILE.DUNGEON: 
            return "Darkness lurks within...";
        default: 
            return "A mysterious location";
    }
}

/// @function get_tile_icon_letter
/// @description Get the icon letter for a tile (used for now, will be replaced with sprites later)
/// @param {TILE} tile_type - The tile type
/// @return {string} The icon letter
function get_tile_icon_letter(tile_type) {
    // For now, just return the same letter as get_tile_letter
    // Later this can be replaced with actual sprite drawing
    return get_tile_letter(tile_type);
}