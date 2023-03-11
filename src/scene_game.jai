#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";
#import "Random";
#import "File";
#import "String";

scene_game_init :: () {
}

scene_game_enter :: () {

}

scene_game_exit :: () {

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
