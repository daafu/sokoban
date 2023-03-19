#if OS == .WINDOWS {
    #import "Windows_Resources";
}

#load "game.jai";
#load "map.jai";
#load "player.jai";
#load "levels.jai";
#load "entity.jai";
#load "crate.jai";
#load "input.jai";
#load "assets.jai";
#load "draw.jai";
#load "ease.jai";
#load "audio.jai";
#load "gamepad.jai";
#load "scene_game.jai";
#load "scene_title.jai";
#load "scene_quit.jai";
#load "scene_splash.jai";

#if OS == .WINDOWS {
    #run disable_runtime_console();
}
