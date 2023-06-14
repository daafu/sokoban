#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "GL";

CELL_WIDTH :: 16;
CELL_HEIGHT :: 16;

// https://lospec.com/palette-list/purplemorning8
pal : [8] Colorf : Colorf.[
    Colorf.{12 / 255.0, 7 / 255.0, 40 / 255.0, 1},         // 0
    Colorf.{28 / 255.0, 23 / 255.0, 68 / 255.0, 1},        // 1
    Colorf.{44 / 255.0, 50 / 255.0, 87 / 255.0, 1},        // 2
    Colorf.{89 / 255.0, 76 / 255.0, 106 / 255.0, 1},       // 3
    Colorf.{160 / 255.0, 91 / 255.0, 118 / 255.0, 1},      // 4
    Colorf.{215 / 255.0, 118 / 255.0, 107 / 255.0, 1},     // 5
    Colorf.{225 / 255.0, 178 / 255.0, 140 / 255.0, 1},     // 6
    Colorf.{222 / 255.0, 231 / 255.0, 173 / 255.0, 1},     // 7
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
    GRASS1;
    GRASS2;
    GRASS3;
    GRASS4;
    GRASS5;
    GRASS6;
    GRASS7;
    GRASS8;
    GRASS9;
    GRASS10;
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

sprite_pack : *Asset;
logo : *Asset;

sprites : [64] PackedSprite;
sprite_fill_corners : [16] PackedSprite;
sprite_fill_sides : [16] PackedSprite;
sprite_title_art : PackedSprite;
sprite_title_text1 : PackedSprite;
sprite_title_text2 : PackedSprite;
sprite_slider_tag : PackedSprite;
sprite_slider_bar : PackedSprite;
sprite_checkbox_off : PackedSprite;
sprite_checkbox_on : PackedSprite;

sprite_help1 : PackedSprite;
sprite_help2 : PackedSprite;

sprite_logo : Rectf;

font_expire : *Asset;

sound_step : *Mixer_Sound_Data;
sound_push : *Mixer_Sound_Data;
sound_option : *Mixer_Sound_Data;
sound_select : *Mixer_Sound_Data;
sound_cancel : *Mixer_Sound_Data;
sound_door_open : *Mixer_Sound_Data;
sound_door_close : *Mixer_Sound_Data;
sound_win : *Mixer_Sound_Data;
sound_scene_swish : *Mixer_Sound_Data;
sound_drawer_open : *Mixer_Sound_Data;
sound_drawer_snap : *Mixer_Sound_Data;

shader_present : *Asset;

sprite_get_index :: (spr :SpriteType) -> PackedSprite {
    si : PackedSprite = sprites[cast (int) spr];
    return si;
}

set_sprite :: (type : SpriteType, name: string) {
    sprites[cast (int) type] = asset_get_sprite(sprite_pack, name.data);
}

assets_init :: () {
    asset_add_pack("res/res.pak");

    logo = asset_load("images/logo_trans.png");
    sprite_pack = asset_load("spritepack.sp");
}

assets_ready :: () {
    set_sprite(.WALL, "wall_top.png");
    set_sprite(.WALL_EDGE, "wall_side.png");
    set_sprite(.GROUND, "ground.png");
    set_sprite(.PLAYER, "player_0.png");
    set_sprite(.CRATE, "crate.png");
    set_sprite(.CRATE_SLOT, "crate_slot.png");
    set_sprite(.DOOR_CLOSED, "door_closed.png");
    set_sprite(.DOOR_OPEN, "door_open.png");

    set_sprite(.UI_HAND, "ui_hand.png");
    set_sprite(.FADE_IN_SLANT, "transition_angle_0.png");
    set_sprite(.FADE_SOLID, "transition_fill.png");
    set_sprite(.FADE_OUT_SLANT, "transition_angle_1.png");

    set_sprite(.GRASS1, "grass_0.png");
    set_sprite(.GRASS2, "grass_1.png");
    set_sprite(.GRASS3, "grass_2.png");
    set_sprite(.GRASS4, "grass_3.png");
    set_sprite(.GRASS5, "grass_4.png");
    set_sprite(.GRASS6, "grass_5.png");
    set_sprite(.GRASS7, "grass_6.png");
    set_sprite(.GRASS8, "grass_7.png");
    set_sprite(.GRASS9, "grass_8.png");
    set_sprite(.GRASS10, "grass_9.png");

    sprite_fill_corners[0b0000] = asset_get_sprite(sprite_pack, "fill_corner_0.png");
    sprite_fill_corners[0b0001] = asset_get_sprite(sprite_pack, "fill_corner_1.png");
    sprite_fill_corners[0b0010] = asset_get_sprite(sprite_pack, "fill_corner_2.png");
    sprite_fill_corners[0b0011] = asset_get_sprite(sprite_pack, "fill_corner_3.png");
    sprite_fill_corners[0b0100] = asset_get_sprite(sprite_pack, "fill_corner_4.png");
    sprite_fill_corners[0b0101] = asset_get_sprite(sprite_pack, "fill_corner_5.png");
    sprite_fill_corners[0b0110] = asset_get_sprite(sprite_pack, "fill_corner_6.png");
    sprite_fill_corners[0b0111] = asset_get_sprite(sprite_pack, "fill_corner_7.png");
    sprite_fill_corners[0b1000] = asset_get_sprite(sprite_pack, "fill_corner_8.png");
    sprite_fill_corners[0b1001] = asset_get_sprite(sprite_pack, "fill_corner_9.png");
    sprite_fill_corners[0b1010] = asset_get_sprite(sprite_pack, "fill_corner_10.png");
    sprite_fill_corners[0b1011] = asset_get_sprite(sprite_pack, "fill_corner_11.png");
    sprite_fill_corners[0b1100] = asset_get_sprite(sprite_pack, "fill_corner_12.png");
    sprite_fill_corners[0b1101] = asset_get_sprite(sprite_pack, "fill_corner_13.png");
    sprite_fill_corners[0b1110] = asset_get_sprite(sprite_pack, "fill_corner_14.png");
    sprite_fill_corners[0b1111] = asset_get_sprite(sprite_pack, "fill_corner_15.png");

    sprite_fill_sides[0b0000] = asset_get_sprite(sprite_pack, "fill_side_0.png");
    sprite_fill_sides[0b0001] = asset_get_sprite(sprite_pack, "fill_side_1.png");
    sprite_fill_sides[0b0010] = asset_get_sprite(sprite_pack, "fill_side_2.png");
    sprite_fill_sides[0b0011] = asset_get_sprite(sprite_pack, "fill_side_3.png");
    sprite_fill_sides[0b0100] = asset_get_sprite(sprite_pack, "fill_side_4.png");
    sprite_fill_sides[0b0101] = asset_get_sprite(sprite_pack, "fill_side_5.png");
    sprite_fill_sides[0b0110] = asset_get_sprite(sprite_pack, "fill_side_6.png");
    sprite_fill_sides[0b0111] = asset_get_sprite(sprite_pack, "fill_side_7.png");
    sprite_fill_sides[0b1000] = asset_get_sprite(sprite_pack, "fill_side_8.png");
    sprite_fill_sides[0b1001] = asset_get_sprite(sprite_pack, "fill_side_9.png");
    sprite_fill_sides[0b1010] = asset_get_sprite(sprite_pack, "fill_side_10.png");
    sprite_fill_sides[0b1011] = asset_get_sprite(sprite_pack, "fill_side_11.png");
    sprite_fill_sides[0b1100] = asset_get_sprite(sprite_pack, "fill_side_12.png");
    sprite_fill_sides[0b1101] = asset_get_sprite(sprite_pack, "fill_side_13.png");
    sprite_fill_sides[0b1110] = asset_get_sprite(sprite_pack, "fill_side_14.png");
    sprite_fill_sides[0b1111] = asset_get_sprite(sprite_pack, "fill_side_15.png");

    sprite_title_art = asset_get_sprite(sprite_pack, "ui_title_art.png");
    sprite_title_text1 = asset_get_sprite(sprite_pack, "ui_title_0.png");
    sprite_title_text2 = asset_get_sprite(sprite_pack, "ui_title_1.png");

    sprite_slider_tag = asset_get_sprite(sprite_pack, "ui_slider_handle.png");
    sprite_slider_bar = asset_get_sprite(sprite_pack, "ui_slider.png");
    sprite_checkbox_off = asset_get_sprite(sprite_pack, "ui_unchecked.png");
    sprite_checkbox_on = asset_get_sprite(sprite_pack, "ui_checked.png");

    sprite_help1 = asset_get_sprite(sprite_pack, "help_rules.png");
    sprite_help2 = asset_get_sprite(sprite_pack, "help_reset.png");

    sprite_logo = Rectf.{0, 0, 1024, 1024};

    font_expire = asset_create_pixel_font(sprite_pack, "fonts/expire", "!\"@$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz", 0, 0, false);

    sound_step = audio_load("res/footstep.wav");
    sound_push = audio_load("res/push.wav");
    sound_option = audio_load("res/option.wav");
    sound_select = audio_load("res/select.wav");
    sound_cancel = audio_load("res/cancel.wav");
    sound_door_open = audio_load("res/door_open.wav");
    sound_door_close = audio_load("res/door_close.wav");
    sound_win = audio_load("res/level_done.wav");
    sound_scene_swish = audio_load("res/swish.wav");
    sound_drawer_open = audio_load("res/drawer_open.wav");
    sound_drawer_snap = audio_load("res/drawer_snap.wav");

    shader_present = asset_load("shaders/retro.fxo");
}
