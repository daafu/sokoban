#import "Basic"; //()(MEMORY_DEBUGGER=true);

// https://lospec.com/palette-list/purplemorning8
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
    UI_HAND;
    FADE_IN_SLANT;
    FADE_OUT_SLANT;
    FADE_SOLID;
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
sprite_fill_corners : [16] SpriteIndex;
sprite_fill_sides : [16] SpriteIndex;
sprite_title_art : Rect;
sprite_title_text1 : Rect;
sprite_title_text2 : Rect;
sprite_slider_tag : Rect;
sprite_slider_bar : Rect;
sprite_checkbox_off : Rect;
sprite_checkbox_on : Rect;

font_expire : SpriteFont;

arts : Simp.Texture;

sound_step : *Mixer_Sound_Data;
sound_push : *Mixer_Sound_Data;
sound_option : *Mixer_Sound_Data;
sound_select : *Mixer_Sound_Data;

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
    set_sprite(.NONE, U16_MAX, U16_MAX);

    set_sprite(.WALL, 0, 0);
    set_sprite(.WALL_EDGE, 0, 1);
    set_sprite(.GROUND, 0, 10);
    set_sprite(.PLAYER, 1, 0);
    set_sprite(.CRATE, 2, 0);
    set_sprite(.CRATE_SLOT, 3, 0);
    set_sprite(.DOOR_CLOSED, 0, 2);
    set_sprite(.DOOR_OPEN, 0, 3);

    set_sprite(.UI_HAND, 16, 6);
    set_sprite(.FADE_IN_SLANT, 17, 6);
    set_sprite(.FADE_SOLID, 18, 6);
    set_sprite(.FADE_OUT_SLANT, 19, 6);

    for v, i : sprite_fill_corners {
        sprite_fill_corners[i].x = 0;
        sprite_fill_corners[i].y = 6;
    }

    for v, i : sprite_fill_sides {
        sprite_fill_sides[i].x = 0;
        sprite_fill_sides[i].y = 7;
    }

    sprite_fill_corners[0b0000].x = 0;
    sprite_fill_corners[0b0001].x = 1;
    sprite_fill_corners[0b0010].x = 2;
    sprite_fill_corners[0b0011].x = 3;
    sprite_fill_corners[0b0100].x = 4;
    sprite_fill_corners[0b0101].x = 5;
    sprite_fill_corners[0b0110].x = 6;
    sprite_fill_corners[0b0111].x = 7;
    sprite_fill_corners[0b1000].x = 8;
    sprite_fill_corners[0b1001].x = 9;
    sprite_fill_corners[0b1010].x = 10;
    sprite_fill_corners[0b1011].x = 11;
    sprite_fill_corners[0b1100].x = 12;
    sprite_fill_corners[0b1101].x = 13;
    sprite_fill_corners[0b1110].x = 14;
    sprite_fill_corners[0b1111].x = 15;

    sprite_fill_sides[0b0000].x = 0;
    sprite_fill_sides[0b0001].x = 1;
    sprite_fill_sides[0b0010].x = 2;
    sprite_fill_sides[0b0011].x = 3;
    sprite_fill_sides[0b0100].x = 4;
    sprite_fill_sides[0b0101].x = 5;
    sprite_fill_sides[0b0110].x = 6;
    sprite_fill_sides[0b0111].x = 7;
    sprite_fill_sides[0b1000].x = 8;
    sprite_fill_sides[0b1001].x = 9;
    sprite_fill_sides[0b1010].x = 10;
    sprite_fill_sides[0b1011].x = 11;
    sprite_fill_sides[0b1100].x = 12;
    sprite_fill_sides[0b1101].x = 13;
    sprite_fill_sides[0b1110].x = 14;
    sprite_fill_sides[0b1111].x = 15;

    sprite_title_art = Rect.{0, 140, 463, 338};
    sprite_title_text1 = Rect.{236, 0, 276, 56};
    sprite_title_text2 = Rect.{306, 56, 206, 38};

    sprite_slider_tag = Rect.{256, 116, 5, 8};
    sprite_slider_bar = Rect.{262, 116, 23, 8};
    sprite_checkbox_off = Rect.{288, 115, 10, 10};
    sprite_checkbox_on = Rect.{304, 115, 10, 10};

    set_font(*font_expire, #char "!", #char "z", .{0, 485}, 32, 9, 9, -1, 0, 6);

    sound_step = audio_load("res/footstep02.wav");
    sound_push = audio_load("res/push.wav");
    sound_option = audio_load("res/vgmenuhighlight.wav");
    sound_select = audio_load("res/vgmenuselect.wav");
}
