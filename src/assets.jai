#import "Basic"; //()(MEMORY_DEBUGGER=true);

pal : [8] Vector4 : Vector4.[
    Vector4.{12 / 255.0, 7 / 255.0, 40 / 255.0, 1},         // 0
    Vector4.{28 / 255.0, 23 / 255.0, 68 / 255.0, 1},        // 1
    Vector4.{44 / 255.0, 50 / 255.0, 87 / 255.0, 1},        // 2
    Vector4.{89 / 255.0, 76 / 255.0, 106 / 255.0, 1},       // 3
    Vector4.{160 / 255.0, 91 / 255.0, 118 / 255.0, 1},      // 4
    Vector4.{215 / 255.0, 118 / 255.0, 107 / 255.0, 1},     // 5
    Vector4.{225 / 255.0, 178 / 255.0, 140 / 255.0, 1},     // 6
    Vector4.{222 / 255.0, 231 / 255.0, 173 / 255.0, 1},     // 7
    ];

SpriteType :: enum u8 {
    NONE;
    WALL;
    WALL_EDGE;
    GROUND;
    PLAYER;
    CRATE;
    CRATE_SLOT;
    DOOR_CLOSED;
    DOOR_OPEN;
}

SpriteIndex :: struct {
    x : u16;
    y : u16;
}

Rect :: struct {
    x: s32;
    y: s32;
    width: s32;
    height: s32;
}

Vector2i :: struct {
    x: s32;
    y: s32;
}

SpriteFont :: struct {
    first_char : u8;
    glyph_width : int;
    glyph_height : int;
    spacing_x : int;
    spacing_y : int;
    space_width: int;
    glyphs: [..] Rect;    
}

sprites : [64] SpriteIndex;
font_expire : SpriteFont;

arts : Simp.Texture;

sound_step : *Mixer_Sound_Data;
sound_push : *Mixer_Sound_Data;

sprite_get_index :: (spr :SpriteType) -> SpriteIndex {
    si : SpriteIndex = sprites[cast (int) spr];
    return si;
}

set_sprite :: (type : SpriteType, cx: int, cy: int) {
    sprites[cast (int) type].x = xx cx;
    sprites[cast (int) type].y = xx cy;
}

set_font :: (font : *SpriteFont, first_char: u8, last_char: u8, pos: Vector2i, col: int, glyph_width: int, glyph_height: int, spacing_x: int, spacing_y: int, space_width: int) {
    if font == null then return;

    font.first_char = first_char;
    font.glyph_width = glyph_width;
    font.glyph_height = glyph_height;
    font.spacing_x = spacing_x;
    font.spacing_y = spacing_y;
    font.space_width = space_width;
    
    char_count := cast(int) last_char - cast(int)first_char + 1;

    array_reset(*font.glyphs);

    glyph_x := pos.x;
    glyph_y := pos.y;
    glyph_col := 0;

    for i: 0..(char_count - 1) {
        if i != 0 && i % col == 0 {
            glyph_x = pos.x;
            glyph_y += xx glyph_height;
        }

        glyph_rect : Rect;
        glyph_rect.x = glyph_x;
        glyph_rect.y = glyph_y;
        glyph_rect.width = xx glyph_width;
        glyph_rect.height = xx glyph_height;

        array_add(*font.glyphs, glyph_rect);

        glyph_x += xx glyph_width;
    }
}

assets_init :: () {
    set_sprite(.NONE, 10, 10);

    set_sprite(.WALL, 0, 0);
    set_sprite(.WALL_EDGE, 0, 1);
    set_sprite(.GROUND, 10, 10);
    set_sprite(.PLAYER, 1, 0);
    set_sprite(.CRATE, 2, 0);
    set_sprite(.CRATE_SLOT, 3, 0);
    set_sprite(.DOOR_CLOSED, 0, 2);
    set_sprite(.DOOR_OPEN, 0, 3);

    set_font(*font_expire, #char "!", #char "z", .{0, 485}, 32, 9, 9, -1, 0, 6);

    sound_step = audio_load("res/footstep02.wav");
    sound_push = audio_load("res/push.wav");
}
