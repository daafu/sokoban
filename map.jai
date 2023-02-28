#import "Basic"; //()(MEMORY_DEBUGGER=true);

TileFlag :: enum u8 {
    NONE :: 0;
    BLOCKING :: 1;
}

Tile :: struct {
    spr : SpriteType;
    color : u8;
    flags : TileFlag;
    entity : *Entity;
}

map_width : int = 0;
map_height : int = 0;

map_tiles : [128 * 128] Tile;
entities : [..] *Entity;
crate_slots : [..] Vector2i;

player : Player;

current_level := 0;

map_init :: () {
    
}

map_draw :: () {
    camera_set((game_width / 2) - (map_width * CELL_WIDTH) / 2, (game_height / 2) - (map_height * CELL_HEIGHT) / 2);

    i : int = 0;

    tx, ty : int = 0;

    for y: 0..map_height - 1 {
        for x: 0..map_width - 1 {
            draw_sprite(map_tiles[i].spr, .{(x * CELL_WIDTH), (y * CELL_HEIGHT)}, pal[map_tiles[i].color]);

            if map_tiles[i].entity != null entity_draw(map_tiles[i].entity);

            i += 1;
        }
    }

    camera_reset();
}

map_load :: (level: int) {
    current_level = level;

    map_remove_all_entities();
    array_reset(*crate_slots);

    level_str := levels[level];

    for value, i : map_tiles {
        map_tiles[i].spr = SpriteType.NONE;
        map_tiles[i].entity = null;
    }

    map_width = 0;
    map_height = 0;

    x := 0;
    y := 0;

    // First pass just measure dimensions
    for 0..level_str.count - 1 {
        if level_str[it] == #char "\n" {            
            if map_width < x then map_width = x;
            map_height += 1;
            x = 0;
            y += 1;
        }
        else {
            x += 1;
        }
    }

    // Load raw level tiles
    x = 0;
    y = 0;
    for 0..level_str.count - 1 {
        if level_str[it] == #char "\n" {
            x = 0;
            y += 1;
        }
        else {
            using map_tiles[x + y * map_width];
            if level_str[it] == {
                case #char "#";
                    spr = .WALL;
                    flags = xx TileFlag.BLOCKING;
                    color = 4;
                case #char " ";
                    spr = .GROUND;
                    flags = 0;
                    color = 1;
                case #char "P";
                    spr = .GROUND;
                    color = 1;
                    flags = 0;

                    player.x = x;
                    player.y = y;

                    map_add_entity(*player);
                case #char "c";
                    spr = .GROUND;
                    color = 1;
                    flags = 0;

                    crate := New(Crate);
                    entity_set_snap_pos(crate, x, y);
                    map_add_entity(crate);
                case #char "o";
                    spr = .CRATE_SLOT;
                    color = 2;
                    flags = 0;
                    array_add(*crate_slots, .{x, y});
                case; spr = .NONE;
            }

            x += 1;
        }
    }

    entity_set_snap_pos(*player, player.x, player.y);

    // Beautify
    for y: 0..map_height - 1 {
        for x: 0..map_width - 1 {
            i := x + y * map_width;
            if map_tiles[i].spr == {
                case .WALL;
                    is_edge := false;
                    if y == map_height - 1 then is_edge = true;
                    else {
                        if map_tiles[i + map_width].spr != .WALL then is_edge = true;
                    }

                    if is_edge then map_tiles[i].spr = .WALL_EDGE;
                case .GROUND;
                    // Do nothing
            }
        }
    }

    print("Map size: % x %\n", map_width, map_height);
}

map_move_entity :: (e: *Entity, dx: int, dy: int) -> bool {
    if e == null return false;

    nx := e.x + dx;
    ny := e.y + dy;

    if map_is_blocking(nx, ny) return false;

    dest_e := map_tiles[nx + (ny * map_width)].entity;
    if dest_e != null {
        if entity_has_flag(e, .PUSHER) && entity_has_flag(dest_e, .PUSHABLE) {
            // See if it can be pushed by moving it in the same direction
            if !map_move_entity(dest_e, dx, dy) return false;
        }
        else {
            return false;
        }
    }

    map_tiles[e.x + (e.y * map_width)].entity = null;
    map_tiles[nx + (ny * map_width)].entity = e;
    e.x = nx;
    e.y = ny;

    return true;
}

map_update :: () {
    for entities {
        if it.type == {
            case .PLAYER; player_update(xx it);
            case; entity_update(it);
        }
    }
}

map_is_blocking :: (x: int, y: int) -> bool {
    if x < 0 || y < 0 || x >= map_width || y >= map_height {
        return true;
    }

    return (map_tiles[x + y * map_width].flags & xx TileFlag.BLOCKING) != 0;
}

map_is_coord_valid :: (x: int, y: int) -> bool {
    if x < 0 || y < 0 || x >= map_width || y >= map_height {
        return false;
    }

    return true;
}

map_add_entity :: (e : *Entity) -> bool {
    if e == null return false;
    if !map_is_coord_valid(e.x, e.y) return false;

    map_tiles[e.x + e.y * map_width].entity = e;
    array_add(*entities, e);

    return true;
}

map_remove_entity :: (e : *Entity) -> bool {
    if e == null return false;

    if map_is_coord_valid(e.x, e.y) {
        map_tiles[e.x + e.y * map_width].entity = null;
    }

    // Free memory for all entities, except for Player
    if e.type != .PLAYER {
        free(e);
    }

    array_unordered_remove_by_value(*entities, e);

    return true;
}

map_remove_all_entities :: () {
    i := 0;

    for y: 0..map_height - 1 {
        for x: 0..map_width - 1 {
            e := map_tiles[i].entity;

            if e != null {
                map_remove_entity(e);
            }

            i += 1;
        }
    }
}

map_reset :: () {
    map_load(current_level);
}

map_all_creates_slotted :: () -> bool {
    for slot: crate_slots {
        if map_tiles[slot.x + slot.y * map_width].entity == null || map_tiles[slot.x + slot.y * map_width].entity.type != .CRATE {
            return false;
        }
    }

    return true;
}