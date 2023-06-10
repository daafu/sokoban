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

Simp :: #import "Simp";

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

time_delta : float;
time_prev : float64;

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

SAVE_VERSION : u32 : 1;

#scope_module

game_set_scene :: (scene: SceneType) {
    if scene != .SPLASH && current_scene != .SPLASH {
        audio_play_sound(sound_scene_swish, true);
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
    should_quit_game = true;
}

game_toggle_fullscreen :: (fullscreen: bool) {
    if fullscreen {
        window_set_fullscreen(.fullscreen_borderless);
    }
    else {
        window_set_fullscreen(.windowed);
    }

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

        time_prev = get_time();

        audio_update();
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
       // print("update\n");
    }
}

render :: () #c_call {
    new_context: Context;
    push_context new_context {
     //   print("render\n");
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
/*
    while !should_quit_game {
        reset_temporary_storage();

        update_window_events();
        gamepad_update();

        audio_update();

        // @Incomplete: Handle resizes in the actual scene drawing, which we currently don't.
        for get_window_resizes() {
            Simp.update_window(it.window);
            if it.window == window {
                should_reinit := (it.width != window_width) || (it.height != window_height);

                window_width  = it.width;
                window_height = it.height;
            }
        }

        for event : events_this_frame {
            if event.type == {
                case .QUIT; {
                    should_quit_game = true;
                    break;
                }

                case .KEYBOARD; {
                    input_handle_keyboard_event(event);
                }
            }
        }

        input_handle_gamepad();

        time_current := get_time();
        time_delta = xx (time_current - time_prev);
        time_prev = time_current;

        update();
        render();

        input_frame_end();

        Simp.swap_buffers(window);

        frame_count += 1;
    }
    */
}

#scope_file

render :: () {
    border_color := Colorf.{8 / 255.0, 8 / 255.0, 8 / 255.0, 1};

    if current_scene == .SPLASH {
        /*
        Simp.set_render_target(window);
        Simp.clear_render_target(pal[0].x, pal[0].y, pal[0].z, pal[0].w);

        Simp.set_shader_for_images(*logo);

        Simp.immediate_begin();
        */
        if current_scene == {
            case .SPLASH; scene_splash_render();
        }
        /*
        Simp.immediate_flush();
        */
    }
    else {
        /*
        Simp.set_render_target(window);
        Simp.clear_render_target(border_color.x, border_color.y, border_color.z, border_color.w);

        Simp.set_render_target(*pixel_surf);
        Simp.clear_render_target(pal[0].x, pal[0].y, pal[0].z, pal[0].w);

        Simp.set_shader_for_images(*arts);

        Simp.immediate_begin();
        */

        if current_scene == {
            case .GAME; scene_game_render();
            case .TITLE; scene_title_render();
        }

        scene_fade();

        // Draw border, necessary for curvature effect
        draw_sprite(sprites[SpriteType.FADE_SOLID], .{0, 0, 1, xx game_height}, border_color);
        draw_sprite(sprites[SpriteType.FADE_SOLID], .{xx (game_width - 1), 0, 1, xx game_height}, border_color);
        draw_sprite(sprites[SpriteType.FADE_SOLID], .{0, 0, xx game_width, 1}, border_color);
        draw_sprite(sprites[SpriteType.FADE_SOLID], .{0, xx (game_height - 1), xx game_width, 1}, border_color);

        /*
        Simp.immediate_flush();

        Simp.set_render_target(window);
        */

        // Calculate render width / height and offsets based on 16:9 aspect requirement
        render_width := window_width;
        render_height := window_height;
        x_offset := 0;
        y_offset := 0;

        aspect_ratio := cast(float)window_width / cast(float)window_height;

        if aspect_ratio < 16.0 / 9.0 {
            // Too tall, bars on top and bottom
            render_height = cast(s32)(cast(float)window_width * (9.0 / 16.0));
            y_offset = (window_height - render_height) / 2;
        }
        else if aspect_ratio > 16.0 / 9.0 {
            // Too wide, bars on left and right
            render_width = cast(s32)(cast(float)window_height * (16.0 / 9.0));
            x_offset = (window_width - render_width) / 2;
        }

        // Setup present
        //immediate_flush();
        //immediate_set_shader(*shader_present);
        /*
        texture_size_loc := glGetUniformLocation(shader_present.gl_handle, "texture0Size");
        screen_native_size_loc := glGetUniformLocation(shader_present.gl_handle, "screenNativeSize");

        glUniform2f(texture_size_loc, xx game_width, xx game_height);
        glUniform2f(screen_native_size_loc, xx render_width, xx render_height);

        set_projection();

        draw_set_texture(pixel_surf);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
*/
        // Draw present
        /*
        Simp.immediate_begin();
        Simp.immediate_quad(Vector2.{xx x_offset, xx (render_height + y_offset)}, Vector2.{xx (render_width + x_offset), xx (render_height + y_offset)}, Vector2.{xx (render_width + x_offset), xx y_offset}, Vector2.{xx x_offset, xx y_offset}, .{1, 1, 1, 1});
        Simp.immediate_flush();
        */
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
    if (scene_reveal >= 1) {
        if current_scene == {
            case .GAME; scene_game_update();
            case .TITLE; scene_title_update();
            case .SPLASH; scene_splash_update();
        }
    }

    fade_speed :: 2.5;

    if next_scene != .NONE {
        scene_reveal -= time_delta * fade_speed;
        if scene_reveal < 0 {
            scene_reveal = 0;
            current_scene = next_scene;
            next_scene = .NONE;

            if current_scene != .SPLASH {
                audio_play_sound(sound_scene_swish, true);
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
        scene_reveal += time_delta * fade_speed;
        if scene_reveal > 1 scene_reveal = 1;
    }
}

init :: () {
    game_width = 640;
    game_height = 360;

    pixel_surf = asset_create_render_target(xx game_width, xx game_height);

    audio_init();
    gamepad_init();

    assets_init();
    map_init();

    scene_title_init();
    scene_game_init();
}
