#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";
#import "Random";
#import "File";
#import "String";

loaded_once := false;

scene_game_init :: () {
}

scene_game_enter :: () {
    if !loaded_once {
        if current_level >= 0 {
            map_load(current_level);
        }

        loaded_once = true;
    }
}

scene_game_exit :: () {
    game_save();
}

scene_game_render :: () {
    map_draw();
}

scene_game_update :: () {
    map_update();

    if input_button_pressed(.ESCAPE) {
        game_set_scene(.TITLE);
    }
}
