#import "Basic"; //()(MEMORY_DEBUGGER=true);

Crate :: struct {
    #as using base: Entity; 
    base.type = .CRATE;
    base.spr = .CRATE;
    base.color = 5;
    base.flags = xx EntityFlags.PUSHABLE;
}

crate_draw :: (e: Entity, yoffset: int) {
    color := pal[e.color];
    if map_tiles[e.x + (e.y * map_width)].spr == .CRATE_SLOT {
        color = pal[6];
    }

    draw_sprite(e.spr, .{xx (e.vx * CELL_WIDTH + 0.5), xx ((e.vy * CELL_HEIGHT + 0.5) + yoffset)}, color);
}
