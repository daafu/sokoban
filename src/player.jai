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
//    si.y = xx ((cast(int)(get_time() * 4)) % 2);
//draw_sprite_pos :: (sprite: PackedSprite, repeat: Vec2f, dest: Vec2f, color: Colorf, flags: s32) #foreign pxl;
    repeat: Vec2f = .{1, 1};
    draw_sprite_pos(si, repeat, .{xx (e.vx * CELL_WIDTH + 0.5), xx ((e.vy * CELL_HEIGHT + 0.5) + yoffset)}, pal[e.color], 0);
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

    btn_repeat :: 20;

    if input_button_pressed(.LEFT, btn_repeat) dx -= 1;
    if input_button_pressed(.RIGHT, btn_repeat) dx += 1;

    if (dx == 0) {
        if input_button_pressed(.UP, btn_repeat) dy -= 1;
        if input_button_pressed(.DOWN, btn_repeat) dy += 1;
    }

    if (dx == 0 && dy == 0) {
        // Did not move at all
        return;
    }

    map_move_entity(p, dx, dy);
}