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

#load "map.jai";
#load "player.jai";
#load "levels.jai";
#load "entity.jai";
#load "crate.jai";
#load "input.jai";
#load "assets.jai";
#load "draw.jai";

Simp :: #import "Simp";

#scope_module

game_width : s32;
game_height : s32;

sound_player : *Sound_Player;

time_delta : float;
time_prev : float64;

#scope_file

window_width : s32 = 1280; 
window_height : s32 = 720;

window : Window_Type;

pixel_surf : Simp.Texture;

last_time : float64;

should_quit_game : bool = false;


#scope_module

main :: () {
    last_time = get_time();

    width  := window_width;
    height := window_height;

    window = create_window(window_name="Game", width=window_width, height=window_height, background_color_rgb = .[12 / 255.0, 7 / 255.0, 40 / 255.0]);
    Simp.set_render_target(window);

    init();
    init_gamepad();

    time_prev = get_time();

    while !should_quit_game {
        reset_temporary_storage();
        
        update_window_events();
        update_gamepad();

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
                    if event.key_code == .ESCAPE {
                        if event.key_pressed {
                            should_quit_game = true;
                        }
                    }
                    else if event.key_code == .F1 {
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

        map_update();

        render();

        input_frame_end();

        Simp.swap_buffers(window);
    }
}



#scope_file

init :: () {
    sound_player = New(Sound_Player);
    sound_player.update_history = true;

    game_width = window_width / 4;
    game_height = window_height / 4;
    
    pixel_surf = Simp.texture_create_render_target(game_width, game_height, .RGBA8, .Render_Target);

    if (!Simp.texture_load_from_file(*arts, "res/arts.png")) {
        print("Failed to load texture");
    }

    assets_init();
    map_init();
    map_load(0);

    print("Initialized");
}

render :: () {
    Simp.set_render_target(*pixel_surf);
    Simp.clear_render_target(pal[0].x, pal[0].y, pal[0].z, pal[0].w);

    Simp.set_shader_for_images(*arts);

    Simp.immediate_begin();

    map_draw();

    if map_all_creates_slotted() {
        draw_text(*font_expire, .{2, 2}, pal[7], "WIN");
    }


    //gamepad_str := tprint("GAMEPAD CON: %  LEFT_STICK: %, %", gamepad.connected, gamepad.left_stick.x, gamepad.left_stick.y);
    //draw_text(*font_expire, .{2, 2}, pal[7], gamepad_str);

    /*
    Simp.immediate_quad(Vector2.{0, 0}, Vector2.{16, 0}, Vector2.{16, 16}, Vector2.{0, 16}, pal[1],
                        Vector2.{0, 1}, Vector2.{16.0 / 512, 1}, Vector2.{16.0 / 512.0, (512 - 16) / 512.0}, Vector2.{0, (512 - 16) / 512.0});
      */                  
    //Simp.immediate_quad(Vector2.{0, 0}, Vector2.{xx pixel_surf.width, 0}, Vector2.{xx pixel_surf.width, xx pixel_surf.height}, Vector2.{0, xx pixel_surf.height});
    Simp.immediate_flush();

    Simp.set_render_target(window);

    Simp.set_shader_for_images(*pixel_surf);

    Simp.immediate_begin();
    Simp.immediate_quad(Vector2.{0, xx window_height}, Vector2.{xx window_width, xx window_height}, Vector2.{xx window_width, 0}, Vector2.{0, 0}, .{1, 1, 1, 1});
    Simp.immediate_flush();
}
