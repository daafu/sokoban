#import "Basic"; //()(MEMORY_DEBUGGER=true);

EntityFlags :: enum u8 {
    PUSHABLE :: 1;
    PUSHER :: 2;
    BLOCKING :: 4;
}

EntityType :: enum u8 {
    NONE :: 0;
    PLAYER;
    CRATE;
}

Entity :: struct {
    type : EntityType;
    x : int;
    y : int;
    vx : float;
    vy : float;
    spr : SpriteType;
    color : u8 = 7;
    flags : u8 = 0;
}

entity_draw :: (e: Entity, yoffset: int) {
    draw_sprite(sprites[e.spr], .{xx (e.vx * CELL_WIDTH + 0.5), xx ((e.vy * CELL_HEIGHT + 0.5) + yoffset)}, pal[e.color]);
}

entity_update :: (e: *Entity) {
    target_x : float = xx e.x;
    target_y : float = xx e.y;

    dx : float = target_x - e.vx;
    dy : float = target_y - e.vy;

    e.vx += dx * 30 * time_delta;
    e.vy += dy * 30 * time_delta;
}

entity_set_snap_pos :: (e: *Entity, x: int, y: int) {
    e.x = x;
    e.y = y;
    e.vx = xx x;
    e.vy = xx y;
}

entity_has_flag :: (e: *Entity, flag: EntityFlags) -> bool {
    if e == null return false;
    if (e.flags & xx flag) != 0 return true;
    return false;
}