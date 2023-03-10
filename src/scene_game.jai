#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";
#import "Random";
#import "File";
#import "String";

scene_game_init :: () {
}

scene_game_render :: () {
    map_draw();
}

scene_game_update :: () {
    map_update();
}
