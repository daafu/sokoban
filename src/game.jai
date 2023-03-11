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
#import "Gamepad";

Simp :: #import "Simp";

#scope_module

SceneType :: enum u8 {
    NONE;
    SPLASH;
    TITLE;
    GAME;
}

game_width : s32;
game_height : s32;

time_delta : float;
time_prev : float64;

#scope_file

window_width : s32 = 1280; 
window_height : s32 = 720;

window : Window_Type;

pixel_surf : Simp.Texture;

last_time : float64;

should_quit_game : bool = false;

current_scene : SceneType;
next_scene : SceneType = .NONE;
scene_reveal : float = 0.0;

#scope_module

game_set_scene :: (scene: SceneType) {
    if current_scene == {
        case .TITLE; scene_title_exit();
        case .GAME; scene_game_exit();
    }

    next_scene = scene;

    if next_scene == {
        case .TITLE; scene_title_enter();
        case .GAME; scene_game_enter();
    }

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

main :: () {
    last_time = get_time();

    width  := window_width;
    height := window_height;

    window = create_window(window_name="Piotr Pushowski and the Crates", width=window_width, height=window_height, background_color_rgb = .[12 / 255.0, 7 / 255.0, 40 / 255.0]);
    Simp.set_render_target(window);

    init();
    game_set_scene(.TITLE);

    time_prev = get_time();

    audio_update();
    audio_play_music("res/Build.ogg", 0.5);

    while !should_quit_game {
        reset_temporary_storage();
        
        update_window_events();
        update_gamepad();

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
                    if event.key_code == .F1 {
                        init_gamepad();
                    }

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
    Simp.set_render_target(*pixel_surf);
    Simp.clear_render_target(pal[0].x, pal[0].y, pal[0].z, pal[0].w);

    Simp.set_shader_for_images(*arts);

    Simp.immediate_begin();

    if current_scene == {
        case .GAME; scene_game_render();
        case .TITLE; scene_title_render();
    }

    scene_fade();

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
    Simp.immediate_flush();

    Simp.set_render_target(window);

    Simp.set_shader_for_images(*pixel_surf);

    Simp.immediate_begin();
    Simp.immediate_quad(Vector2.{0, xx window_height}, Vector2.{xx window_width, xx window_height}, Vector2.{xx window_width, 0}, Vector2.{0, 0}, .{1, 1, 1, 1});
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
        print("Failed to load texture");
    }

    audio_init();
    init(sound_player, xx window, true, true);
    
    init_gamepad();
    assets_init();
    map_init();

    scene_title_init();
    scene_game_init();

    print("Initialized");
}
