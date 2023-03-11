#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";
#import "Random";
#import "File";
#import "String";

#scope_file

OptionType :: enum {
    CONTINUE;
    NEW_GAME;
    QUIT;
}

Option :: struct {
    type: OptionType;
    name: string;
    enabled: bool = false;
}

reveal: float = 0;
options: [3] Option = .[.{.CONTINUE, "CONTINUE", true}, .{.NEW_GAME, "NEW GAME", true}, .{.QUIT, "QUIT", true}];
first_option_y :: 160;
option_spacing :: 20;
hand_pos : float = xx first_option_y;
current_option := 0;

#scope_module

scene_title_init :: () {

}

scene_title_enter :: () {
    options[0].enabled = map_is_loaded();

    reveal = 0;

    // Find first enabled option
    for i : 0..options.count - 1 {
        if options[i].enabled {
            current_option = i;
            hand_pos : float = xx (first_option_y + (current_option * option_spacing));
            break;
        }
    }    
}

scene_title_exit :: () {

}

scene_title_render :: () {
    // Menu
    offset := 0;
    t := util_part_progress(reveal, 0.75, 1);
    if t > 0 {
        draw_menu(t);
    }

    // Title Text
    t = util_part_progress(reveal, 0.5, 0.7);
    t = ease_interp(.BOUNCE_IN, 0.0, 1.0, (1 - t));
    offset = xx (t * (-100));

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

    hand_pos_dest : float = xx (first_option_y + (current_option * option_spacing));
    hand_pos = xx lerp(hand_pos, hand_pos_dest, (time_delta * 25));

    if input_button_pressed(.UP) {
        current_option -= 1;
        while (current_option < 0 || !options[current_option].enabled) {
            current_option -= 1;
            if (current_option < 0) {
                current_option = options.count - 1;
            }
        }
    }

    if input_button_pressed(.DOWN) {
        current_option += 1;
        while (current_option >= options.count || !options[current_option].enabled) {
            current_option += 1;
            if (current_option >= options.count) {
                current_option = 0;
            }
        }
    }

    if current_option < 0 current_option = 0;
    if current_option >= options.count current_option = options.count - 1;

    if input_button_pressed(.SELECT) {
        if options[current_option].enabled {
            if options[current_option].type == {
                case .CONTINUE;
                    game_set_scene(.GAME);
                    
                case .NEW_GAME;
                    map_load(0);
                    game_set_scene(.GAME);

                case .QUIT;
                    game_quit();
            }
        }
    }
}

#scope_file
draw_menu :: (t: float) {
    t1 := ease_interp(.ELASTIC_IN, 0.0, 1.0, (1 - t));
    offset : int = xx (t1 * 300);

    for i : 0..options.count - 1 {
        color := pal[7];
        if !options[i].enabled color = pal[2];
        draw_text(*font_expire, .{xx (125 + offset), xx (first_option_y + (i * option_spacing))}, color, options[i].name);
    }

    //draw_text(*font_expire, .{xx (125 + offset), 180}, pal[7], "NEW GAME");
    //draw_text(*font_expire, .{xx (125 + offset), 200}, pal[7], "QUIT");

    pointer_offset : float = xx (sin(get_time() * 10) * 4);

    draw_sprite(sprite_get_index(.UI_HAND), .{xx (105 + offset + pointer_offset), xx (hand_pos - 2)}, pal[7]);
}