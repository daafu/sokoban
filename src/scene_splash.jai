#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";
#import "Random";
#import "File";
#import "String";

#scope_file

reveal: float = 0;
done: bool = false;

#scope_module

scene_splash_init :: () {
}

scene_splash_enter :: () {
    reveal = 0;
}

scene_splash_exit :: () {
    //audio_play_music("res/music_build.ogg", 0.5);
}

scene_splash_render :: () {
    height : float = xx (window_height * 0.75);
    width := height;

    x := (window_width / 2) - (width / 2);
    y := (window_height / 2) - (height / 2);

    draw_set_texture(logo);
    draw_copy(sprite_logo, .{x, y, width, height});
}

scene_splash_update :: () {
    reveal += time_per_update() * 0.65;
    if reveal > 1 {
        if !done {
            game_set_scene(.TITLE);
            done = true;
        }

        reveal = 1;
    }
}
