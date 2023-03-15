#import "Basic"; //()(MEMORY_DEBUGGER=true);

Player :: struct {
    #as using base: Entity; 
    base.type = .PLAYER;
    base.spr = .PLAYER;
    base.color = 7;
    base.flags = xx EntityFlags.PUSHER;    
}

player_draw :: (e: Entity, yoffset: int) {
    si := sprite_get_index(e.spr);
    si.y = xx ((cast(int)(get_time() * 4)) % 2);
    draw_sprite(si, .{xx (e.vx * CELL_WIDTH + 0.5), xx ((e.vy * CELL_HEIGHT + 0.5) + yoffset)}, pal[e.color]);
}

player_update :: (p : *Player) {
    entity_update(p);

    if trans_next_level {
        return;
    }

    dx := 0;
    dy := 0;

    if input_button_pressed(.RESET) {
        map_reset();
        return;
    }

    if input_button_pressed(.LEFT) dx -= 1;
    if input_button_pressed(.RIGHT) dx += 1;

    if (dx == 0) {
        if input_button_pressed(.UP) dy -= 1;
        if input_button_pressed(.DOWN) dy += 1;
    }

    if (dx == 0 && dy == 0) {
        // Did not move at all
        return;
    }

    map_move_entity(p, dx, dy);
}