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

#scope_file

window_width : s32 = 1280; 
window_height : s32 = 720;

prev_window_info : Saved_Window_Info;

window : Window_Type;

pixel_surf : Simp.Texture;

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
    audio_play_sound(sound_scene_swish, true);

    if current_scene == {
        case .TITLE; scene_title_exit();
        case .GAME; scene_game_exit();
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
    fullscreen_success, window_width, window_height := toggle_fullscreen(window, fullscreen, *prev_window_info);
}

game_save :: () {
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

    // Create path incase it doesn't exist
    make_directory_if_it_does_not_exist(save_game_path, false);

    fp, success := file_open(save_game_file, true, false, false);
    if success {
        success = file_write(*fp, xx *data, xx size_of(SavedGame));
        file_close(*fp);
    }
}

game_load :: () {
    data : SavedGame;

    fp, success := file_open(save_game_file, false, false, false);
    if success {
        // Read out version first
        version : u32 = 0;
        success = file_read(*fp, xx *version, xx size_of(type_of(version)));
        if (success) {
            file_seek(fp, 0, .START);

            if version == SAVE_VERSION {
                success, bytes_read := file_read(*fp, xx *data, size_of(SavedGame));

                if (success) {
                    options_load(*data);
                    map_load(*data);
                }
            }
            else {
                // TODO Version conversion
            }

            file_close(*fp);
        }
    }

    //file_read :: (f: File, vdata: *void, bytes_to_read: s64) -> (success: bool, bytes_read: s64) {
}

main :: () {
    last_time = get_time();

    save_game_path = sprint("%/Piotr", get_path_os_saved_games());
    replace_chars(save_game_path, "\\", #char "/");
    save_game_file = sprint("%/saved_game.dat", save_game_path);

    game_load();

    width  := window_width;
    height := window_height;

    window = create_window(window_name="Piotr Pushowski and the Crates", width=window_width, height=window_height, background_color_rgb = .[12 / 255.0, 7 / 255.0, 40 / 255.0]);

    if (options_get_fullscreen()) {
        game_toggle_fullscreen(true);
    }
    
    Simp.set_render_target(window);

    init();
    game_set_scene(.TITLE);
    
    time_prev = get_time();

    audio_update();
    audio_play_music("res/music_build.ogg", 0.5);

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

//                if should_reinit my_init_fonts();
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
    }
}

#scope_file

render :: () {
    border_color := Vector4.{8 / 255.0, 8 / 255.0, 8 / 255.0, 1};

    Simp.set_render_target(window);
    Simp.clear_render_target(border_color.x, border_color.y, border_color.z, border_color.w);

    Simp.set_render_target(*pixel_surf);
    Simp.clear_render_target(pal[0].x, pal[0].y, pal[0].z, pal[0].w);

    Simp.set_shader_for_images(*arts);

    Simp.immediate_begin();

    if current_scene == {
        case .GAME; scene_game_render();
        case .TITLE; scene_title_render();
    }

    scene_fade();

    // Draw border, necessary for curvature effect
    draw_sprite(.FADE_SOLID, .{0, 0, 1, game_height}, border_color);
    draw_sprite(.FADE_SOLID, .{game_width - 1, 0, 1, game_height}, border_color);
    draw_sprite(.FADE_SOLID, .{0, 0, game_width, 1}, border_color);
    draw_sprite(.FADE_SOLID, .{0, game_height - 1, game_width, 1}, border_color);
/*
    draw_sprite(.CRATE, .{0, 0}, pal[0]);
    draw_sprite(.CRATE, .{20, 0}, pal[1]);
    draw_sprite(.CRATE, .{40, 0}, pal[2]);
    draw_sprite(.CRATE, .{60, 0}, pal[3]);

    draw_sprite(.CRATE, .{80, 0}, pal[4]);
    draw_sprite(.CRATE, .{100, 0}, pal[5]);
    draw_sprite(.CRATE, .{120, 0}, pal[6]);
    draw_sprite(.CRATE, .{140, 0}, pal[7]);
*/
    //analog := gamepad_get_analog();
    //draw_text(*font_expire, .{ 2, 2 }, pal[7], tprint("% %", analog.x, analog.y));

    Simp.immediate_flush();

    Simp.set_render_target(window);

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
    immediate_flush();
    immediate_set_shader(*shader_present);
    texture_size_loc := glGetUniformLocation(shader_present.gl_handle, "texture0Size");
    screen_native_size_loc := glGetUniformLocation(shader_present.gl_handle, "screenNativeSize");

    glUniform2f(texture_size_loc, xx game_width, xx game_height);
    glUniform2f(screen_native_size_loc, xx render_width, xx render_height);

    set_projection();
    immediate_set_texture(*pixel_surf);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    // Draw present
    Simp.immediate_begin();
    Simp.immediate_quad(Vector2.{xx x_offset, xx (render_height + y_offset)}, Vector2.{xx (render_width + x_offset), xx (render_height + y_offset)}, Vector2.{xx (render_width + x_offset), xx y_offset}, Vector2.{xx x_offset, xx y_offset}, .{1, 1, 1, 1});
    Simp.immediate_flush();
}

scene_fade :: () {
    fade_color := Vector4.{0, 0, 0, 1};

    t := ease_interp(.SINE_IN, 0.0, 1.0, scene_reveal);

    x_offset : int = xx (((t * 1.75) * game_width) - 450);
    x_stagger : int = 0;
    y_offset : int = 0;

    while y_offset < game_height {
        draw_sprite(.FADE_IN_SLANT, .{xx (x_offset + x_stagger), xx y_offset}, fade_color);
        draw_sprite(.FADE_SOLID, .{xx (x_offset + x_stagger + 16), xx y_offset, xx (game_width * 1.75), 16}, fade_color);
        y_offset += 16;
        x_offset += 16;
        //x_stagger += 16;
    }    
}

update :: () {
    if (scene_reveal >= 1) {
        if current_scene == {
            case .GAME; scene_game_update();
            case .TITLE; scene_title_update();
        }
    }

    fade_speed :: 2.5;

    if next_scene != .NONE {
        scene_reveal -= time_delta * fade_speed;
        if scene_reveal < 0 {
            scene_reveal = 0;
            current_scene = next_scene;
            next_scene = .NONE;

            audio_play_sound(sound_scene_swish, true);

            if current_scene == {
                case .TITLE; scene_title_enter();
                case .GAME; scene_game_enter();
                case .QUIT; scene_quit_enter();
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
    
    pixel_surf = Simp.texture_create_render_target(game_width, game_height, .RGBA8, .Render_Target);

    if (!Simp.texture_load_from_file(*arts, "res/arts.png")) {
        print("Failed to load texture\n");
    }

    audio_init();
    gamepad_init();

    init(sound_player, xx window, true, true);
    
    assets_init();
    map_init();

    scene_title_init();
    scene_game_init();

    print("Initialized\n");
}
