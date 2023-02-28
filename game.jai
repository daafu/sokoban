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

#load "map.jai";
#load "player.jai";
#load "levels.jai";
#load "entity.jai";
#load "crate.jai";
#load "input.jai";
#load "assets.jai";

Simp :: #import "Simp";

CELL_WIDTH :: 16;
CELL_HEIGHT :: 16;

window_width : s32 = 1280; 
window_height : s32 = 720;
game_width : s32;
game_height : s32;

window : Window_Type;

camera_x : int = 0;
camera_y : int = 0;

sound_player : *Sound_Player;

pixel_surf : Simp.Texture;
arts : Simp.Texture;

last_time : float64;

should_quit_game : bool = false;

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

draw_sprite :: (spr : SpriteType, draw_pos: Vector2, color: Vector4) {
    pos : Vector2 = draw_pos;
    pos.x += camera_x;
    pos.y += camera_y;

    si := sprite_get_index(spr);

    uv0 := Vector2.{(si.x * cast(float) CELL_WIDTH) / arts.width, (arts.height - (si.y * CELL_HEIGHT)) / cast (float) arts.height};
    Simp.immediate_quad(pos, Vector2.{pos.x + CELL_WIDTH, pos.y}, Vector2.{pos.x + CELL_WIDTH, pos.y + CELL_HEIGHT}, Vector2.{pos.x, pos.y + CELL_HEIGHT}, color,
                uv0,
                Vector2.{uv0.x + (cast(float) CELL_WIDTH / arts.width), uv0.y},
                Vector2.{uv0.x + (cast(float) CELL_WIDTH / arts.width), uv0.y - (cast(float) CELL_HEIGHT / arts.height)},
                Vector2.{uv0.x, uv0.y - (cast(float) CELL_HEIGHT / arts.height)}
                );
}

camera_set :: (x: int, y: int) {
    camera_x = x;
    camera_y = y;
}

camera_reset :: () {
    camera_x = 0;
    camera_y = 0;
}

render :: () {
    Simp.set_render_target(*pixel_surf);
    Simp.clear_render_target(pal[0].x, pal[0].y, pal[0].z, pal[0].w);

    Simp.set_shader_for_images(*arts);

    Simp.immediate_begin();

    map_draw();

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

main :: () {
    last_time = get_time();

    width  := window_width;
    height := window_height;

    window = create_window(window_name="Game", width=window_width, height=window_height, background_color_rgb = .[12 / 255.0, 7 / 255.0, 40 / 255.0]);
    Simp.set_render_target(window);

    init();

    while !should_quit_game {
        reset_temporary_storage();
        
        update_window_events();

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
            if event.type == .QUIT {
                should_quit_game = true;
                break;
            }

            if event.key_code == .ESCAPE 
                if event.key_pressed should_quit_game = true;

            if event.type == .KEYBOARD {
                input_handle_keyboard_event(event);
            }
        }        

        map_update();

        render();

        input_frame_end();

        Simp.swap_buffers(window);
    }
}
