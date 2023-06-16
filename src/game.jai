#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Hash_Table";
#import "Math";
#import "Random";
#import "Sound_Player";
#import "Wav_File";
#import "stb_vorbis";
#import "Window_Creation";
#import "File";
#import "String";
#import "Thread";
#import "Input";
#import "System";

#import "SDL";

#scope_module

SceneType :: enum u8 {
    NONE;
    SPLASH;
    TITLE;
    GAME;
    QUIT;
}

game_width : s32;
game_height : s32;

window_width : s32 = 1280;
window_height : s32 = 720;

SavedGame :: struct {
    version: u32;
    res_width: u32;
    res_height: u32;
    sfx_volume: u32;
    music_volume: u32;
    fullscreen: u32;
    current_level: s32;
}

frame_count : int = 0;

#scope_file

prev_window_info : Saved_Window_Info;

window : Window_Type;

pixel_surf : *Asset;

last_time : float64;

should_quit_game : bool = false;

current_scene : SceneType;
next_scene : SceneType = .NONE;
scene_reveal : float = 0.0;

save_game_file : string;
save_game_path : string;

assets_load_finished : bool = false;

SAVE_VERSION : u32 : 1;

#scope_module

game_set_scene :: (scene: SceneType) {
    if scene != .SPLASH && current_scene != .SPLASH {
        audio_play(sound_scene_swish, AUDIO_SFX, false, 10);
    }

    if current_scene == {
        case .TITLE; scene_title_exit();
        case .GAME; scene_game_exit();
        case .SPLASH; scene_splash_exit();
    }

    next_scene = scene;

    // Reveal immediately if there is no other scene
    if current_scene == .NONE {
        current_scene = next_scene;
        scene_reveal = 1.0;
        next_scene = .NONE;
    }
}

game_quit :: () {
    pxl_quit();
}

game_toggle_fullscreen :: (fullscreen: bool) {
    window_set_fullscreen(.windowed);
/*
    if fullscreen {
        window_set_fullscreen(.fullscreen_borderless);
    }
    else {
        window_set_fullscreen(.windowed);
    }
*/
    window_get_size(xx *window_width, xx *window_height);
}

game_save :: () {
    filename := "saved_game.dat";

    data := SavedGame.{
        SAVE_VERSION,
        1280,
        720,
        0,
        0,
        0,
        -1,
    };

    options_save(*data);
    map_save(*data);

    record_write(filename.data, 0, xx *data, xx size_of(SavedGame), null);
}

game_load :: () {
    data : SavedGame;

    filename := "saved_game.dat";

    if record_exits(filename.data) {
        // Read out version first
        version : u32 = 0;

        if .success == record_read(filename.data, 0, xx *version, xx size_of(type_of(version)), null) {
            if version == SAVE_VERSION {
                if .success == record_read(filename.data, 0, xx *data, xx size_of(SavedGame), null) {
                    options_load(*data);
                    map_load(*data);
                }
            }
            else {
                // TODO Saved game version conversion
            }
        }
    }
}

init :: () -> Result #c_call {
    new_context: Context;
    push_context new_context {
        print("init\n");

        window_set_res(1280, 720, true);
        window_set_title("Piotr Pushowski and the Crates");

        game_load();

        if (options_get_fullscreen()) {
            game_toggle_fullscreen(true);
        }

        init();
        game_set_scene(.SPLASH);
    }

    return .success;
}

deinit :: () #c_call {
    new_context: Context;
    push_context new_context {
        print("deinit\n");
    }
}

update :: () #c_call {
    new_context: Context;
    push_context new_context {
       update();
    }
}

render :: () #c_call {
    new_context: Context;
    push_context new_context {
        render();
    }
}

main :: () {
    callbacks := PxlCallbacks.{
        init,
        deinit,
        update,
        render
    };

    pxl_entry("BadCastle", "Piotr", callbacks, 0, null);
}

#scope_file

render :: () {
    border_color := Colorf.{8 / 255.0, 8 / 255.0, 8 / 255.0, 1};

    if current_scene == .SPLASH {
        draw_set_render_target(null);
        draw_camera(0, 0, xx window_width, xx window_height);
        draw_clear(pal[0]);

        if current_scene == {
            case .SPLASH; scene_splash_render();
        }
    }
    else {
        draw_set_render_target(null);
        draw_clear(border_color);

        draw_set_render_target(pixel_surf);
        draw_clear(pal[0]);
        draw_camera(0, 0, xx game_width, xx game_height);

        draw_set_texture(sprite_pack);

        if current_scene == {
            case .GAME; scene_game_render();
            case .TITLE; scene_title_render();
        }

        scene_fade();

        // Draw border, necessary for curvature effect
        draw_rect(.{0, 0, xx game_width, xx game_height}, 1, border_color);

        draw_set_render_target(null);
        draw_camera(0, 0, xx window_width, xx window_height);

        draw_set_texture(pixel_surf);
        draw_set_shader(shader_present);

        draw_copy(.{0, 0, xx game_width, xx game_height}, .{0, 0, xx window_width, xx window_height});

        draw_set_shader(null);
    }
}

scene_fade :: () {
    fade_color := Colorf.{0, 0, 0, 1};

    t := ease_interp(.SINE_IN, 0.0, 1.0, scene_reveal);

    x_offset : int = xx (((t * 1.75) * game_width) - 450);
    x_stagger : int = 0;
    y_offset : int = 0;

    while y_offset < game_height {
        draw_sprite(sprites[SpriteType.FADE_IN_SLANT], .{xx (x_offset + x_stagger), xx y_offset}, fade_color);
        draw_sprite(sprites[SpriteType.FADE_SOLID], .{xx (x_offset + x_stagger + 16), xx y_offset, xx (game_width * 1.75), 16}, fade_color);
        y_offset += 16;
        x_offset += 16;
    }
}

update :: () {
    if asset_load_progress() < 1 {
        return;
    }
    else if assets_load_finished == false {
        assets_ready();
        assets_load_finished = true;
    }

    if (scene_reveal >= 1) {
        if current_scene == {
            case .GAME; scene_game_update();
            case .TITLE; scene_title_update();
            case .SPLASH; scene_splash_update();
        }
    }

    fade_speed :: 2.5;

    if next_scene != .NONE {
        scene_reveal -= time_per_update() * fade_speed;
        if scene_reveal < 0 {
            scene_reveal = 0;
            current_scene = next_scene;
            next_scene = .NONE;

            if current_scene != .SPLASH {
                audio_play(sound_scene_swish, AUDIO_SFX, false, 10);
            }

            if current_scene == {
                case .TITLE; scene_title_enter();
                case .GAME; scene_game_enter();
                case .QUIT; scene_quit_enter();
                case .SPLASH; scene_splash_enter();
            }
        }
    }
    else {
        scene_reveal += time_per_update() * fade_speed;
        if scene_reveal > 1 scene_reveal = 1;
    }

    // Update volume if needed
    sfx_volume := options_get_sfx_volume();
    music_volume := options_get_music_volume();

    audio_set_domain_volume(sfx_volume, AUDIO_SFX);
    audio_set_domain_volume(music_volume, AUDIO_MUSIC);

    input_check_gamepad();
}

init :: () {
    game_width = 640;
    game_height = 360;

    pixel_surf = asset_create_render_target(xx game_width, xx game_height);
    asset_set_texture_interpolation(pixel_surf, .nearest);

    gamepad_init();
    input_simulate_dpad_with_analog(.simulate_4way);

    assets_init();
    map_init();

    scene_title_init();
    scene_game_init();
}
