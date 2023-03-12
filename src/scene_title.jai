#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";
#import "Random";
#import "File";
#import "String";

#scope_file

OptionType :: enum {
    CONTINUE;
    NEW_GAME;
    OPTIONS;
    QUIT;
    SFX_VOL;
    MUSIC_VOL;
    FULLSCREEN;
    BACK;
}

OptionValueType :: enum {
    NONE;
    INTEGER;
    BOOL;
}

Option :: struct {
    type: OptionType;
    name: string;
    enabled: bool = false;
    value_type : OptionValueType = .NONE;
    value_int : int = 0;
    value_int_min : int = 0;
    value_int_max : int = 5;
}

reveal: float = 0;
options_main: [4] Option = .[
    .{.CONTINUE, "CONTINUE", true, .NONE, 0, 0, 0},
    .{.NEW_GAME, "NEW GAME", true, .NONE, 0, 0, 0},
    .{.OPTIONS, "OPTIONS", true, .NONE,  0, 0, 0},
    .{.QUIT, "QUIT", true, .NONE, 0, 0, 0}];

options_config: [4] Option = .[
    .{.SFX_VOL, "SFX VOLUME", true, .INTEGER, 3, 0, 4},
    .{.MUSIC_VOL, "MUSIC VOLUME", true, .INTEGER, 3, 0, 4},
    .{.FULLSCREEN, "FULLSCREEN", true, .BOOL, 1, 0, 1},
    .{.BACK, "BACK", true, .NONE, 0, 0, 0}];

current_options : [] Option;
next_options : [] Option = .[];

options_reveal : float = 0;

first_option_y :: 160;
option_spacing :: 20;
hand_pos : float = xx first_option_y;
current_option := 0;


#scope_module

// These are a little backwards, getting value from UI rather than the other way around!
options_get_sfx_volume :: () -> float {
    return (cast (float) options_config[0].value_int) / (cast (float) options_config[0].value_int_max);
}

options_get_music_volume :: () -> float {
    return (cast (float) options_config[1].value_int) / (cast (float) options_config[1].value_int_max);
}

options_get_fullscreen :: () -> bool {
    return xx options_config[2].value_int;
}

options_save :: (opts: *SavedGame) {
    opts.sfx_volume = xx options_config[0].value_int;
    opts.music_volume = xx options_config[1].value_int;
    opts.fullscreen = xx options_config[2].value_int;
}

options_load :: (opts: *SavedGame) {
    options_config[0].value_int = xx opts.sfx_volume ;
    options_config[1].value_int = xx opts.music_volume;
    options_config[2].value_int = xx opts.fullscreen;
}

scene_title_init :: () {
    current_options = options_main;
    options_main[0].enabled = map_save_available();

    set_first_valid_option();
}

scene_title_enter :: () {
    options_main[0].enabled = map_save_available();

    reveal = 0;
    options_reveal = 0;
    current_options = options_main;
    set_first_valid_option();
}

scene_title_exit :: () {

}

scene_title_render :: () {
    // Menu
    offset := 0;
    t := options_reveal;
    if t > 0 {
        draw_menu(t);
    }

    // Title Text
    t = util_part_progress(reveal, 0.5, 0.7);
    t = ease_interp(.BOUNCE_IN, 0.0, 1.0, (1 - t));
    offset = xx (t * (-110));

    draw_copy(*sprite_title_text1, Vector2i.{12, xx (8 + offset)}, Vector4.{1, 1, 1, 1});
    draw_copy(*sprite_title_text2, Vector2i.{48, xx (64 + offset)}, Vector4.{1, 1, 1, 1});

    // Art
    t = util_part_progress(reveal, 0, 0.4);
    t = ease_interp(.EXPO_IN, 0.0, 1.0, (1 - t));
    offset = xx (t * (-game_width));

    draw_copy(*sprite_title_art, Vector2i.{xx (180 + offset), 18}, Vector4.{1, 1, 1, 1});
}

scene_title_update :: () {
    reveal += time_delta * 0.65;
    if reveal > 1 reveal = 1;

    if reveal >= 1 && next_options.count == 0 {
        options_reveal += time_delta * 1.25;
        if options_reveal > 1 options_reveal = 1;
    }
    else {
        options_reveal -= time_delta * 1.75;
        if options_reveal < 0 {
            options_reveal = 0;
            if next_options.count != 0 {
                current_options = next_options;
                next_options = .[];
                set_first_valid_option();
            }
        }
    }

    hand_pos_dest : float = xx (first_option_y + (current_option * option_spacing));
    hand_pos = xx lerp(hand_pos, hand_pos_dest, (time_delta * 40));

    prev_option := current_option;

    if input_button_pressed(.UP) {
        current_option -= 1;
        while (current_option < 0 || !current_options[current_option].enabled) {
            current_option -= 1;
            if (current_option < 0) {
                current_option = current_options.count - 1;
            }
        }
    }

    if input_button_pressed(.DOWN) {
        current_option += 1;
        while (current_option >= current_options.count || !current_options[current_option].enabled) {
            current_option += 1;
            if (current_option >= current_options.count) {
                current_option = 0;
            }
        }
    }

    if current_options[current_option].value_type == .INTEGER {
        if input_button_pressed(.LEFT) {
            if current_options[current_option].value_int > current_options[current_option].value_int_min {
                current_options[current_option].value_int -= 1;
                audio_play_sound(sound_select, true);
            }
        }
        else if input_button_pressed(.RIGHT) {
            if current_options[current_option].value_int < current_options[current_option].value_int_max {
                current_options[current_option].value_int += 1;
                audio_play_sound(sound_select, true);
            }
        }
    }

    if current_option < 0 current_option = 0;
    if current_option >= current_options.count current_option = current_options.count - 1;

    if input_button_pressed(.SELECT) {
        if current_options[current_option].enabled {
            if current_options[current_option].type == {
                // Main
                case .CONTINUE;
                    game_set_scene(.GAME);
                    audio_play_sound(sound_select, true);
                    
                case .NEW_GAME;
                    map_load(0);
                    game_set_scene(.GAME);
                    audio_play_sound(sound_select, true);

                case .OPTIONS;
                    next_options = options_config;
                    audio_play_sound(sound_select, true);

                case .QUIT;
                    game_save();
                    game_set_scene(.QUIT);
                    audio_play_sound(sound_cancel, true);

                // Config
                case .SFX_VOL;
                    
                case .MUSIC_VOL;

                case .FULLSCREEN;
                    if options_config[2].value_int == 0 {
                        options_config[2].value_int = 1;
                    }
                    else {
                        options_config[2].value_int = 0;
                    }

                    game_toggle_fullscreen(options_get_fullscreen());

                    audio_play_sound(sound_select, true);

                case .BACK;
                    game_save();
                    next_options = options_main;
                    audio_play_sound(sound_cancel, true);
            }
        }
    }

    // Back out of options using cancel button
    if input_button_pressed(.CANCEL) && current_options.data == options_config.data {
        game_save();
        audio_play_sound(sound_cancel, true);
        next_options = options_main;
    }

    if prev_option != current_option {
        audio_play_sound(sound_option, true);
    }
}

#scope_file
draw_menu :: (t: float) {
    t1 := ease_interp(.ELASTIC_IN, 0.0, 1.0, (1 - t));
    offset : int = xx (t1 * 300);

    for i : 0..current_options.count - 1 {
        color := pal[7];
        if !current_options[i].enabled color = pal[2];

        if current_options[i].value_type == {
            case .NONE;
                draw_text(*font_expire, .{xx (125 + offset), xx (first_option_y + (i * option_spacing))}, color, current_options[i].name);

            case .INTEGER;
                draw_text(*font_expire, .{xx (125 + offset), xx (first_option_y + (i * option_spacing))}, color, current_options[i].name);
                draw_copy(*sprite_slider_bar, .{xx (125 + offset + 100), xx (first_option_y + (i * option_spacing))}, pal[3]);
                draw_copy(*sprite_slider_tag, .{xx (125 + offset + 103 + (current_options[i].value_int * 3)), xx (first_option_y + (i * option_spacing))}, pal[7]);

            case .BOOL;
                draw_text(*font_expire, .{xx (125 + offset), xx (first_option_y + (i * option_spacing))}, color, current_options[i].name);
                if (current_options[i].value_int > 0) {
                    draw_copy(*sprite_checkbox_on, .{xx (125 + offset + 100), xx (first_option_y + (i * option_spacing))}, pal[7]);
                }
                else {
                    draw_copy(*sprite_checkbox_off, .{xx (125 + offset + 100), xx (first_option_y + (i * option_spacing))}, pal[3]);
                }
        }
    }

    pointer_offset : float = xx (sin(get_time() * 10) * 4);

    draw_sprite(sprite_get_index(.UI_HAND), .{xx (105 + offset + pointer_offset), xx (hand_pos - 2)}, pal[7]);
}

set_first_valid_option :: () {
    // Find first enabled option
    for i : 0..current_options.count - 1 {
        if current_options[i].enabled {
            current_option = i;
            hand_pos : float = xx (first_option_y + (current_option * option_spacing));
            break;
        }
    }
}