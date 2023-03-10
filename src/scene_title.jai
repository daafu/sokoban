#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";
#import "Random";
#import "File";
#import "String";

#scope_file

reveal: float = 0;

#scope_module

scene_title_init :: () {
}

scene_title_render :: () {

    draw_text(*font_expire, .{125, 160}, pal[7], "CONTINUE");
    draw_text(*font_expire, .{125, 180}, pal[7], "NEW GAME");
    draw_text(*font_expire, .{125, 200}, pal[7], "QUIT");

    draw_copy(*sprite_title_text1, Vector2i.{12, 8}, Vector4.{1, 1, 1, 1});
    draw_copy(*sprite_title_text2, Vector2i.{48, 64}, Vector4.{1, 1, 1, 1});

    draw_copy(*sprite_title_art, Vector2i.{180, 18}, Vector4.{1, 1, 1, 1});
}

scene_title_update :: () {
    reveal += time_delta * 0.5;
}
