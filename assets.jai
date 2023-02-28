#import "Basic"; //()(MEMORY_DEBUGGER=true);

pal : [8] Vector4 : Vector4.[
    Vector4.{12 / 255.0, 7 / 255.0, 40 / 255.0, 1},         // 0
    Vector4.{28 / 255.0, 23 / 255.0, 68 / 255.0, 1},        // 1
    Vector4.{44 / 255.0, 50 / 255.0, 87 / 255.0, 1},        // 2
    Vector4.{89 / 255.0, 76 / 255.0, 106 / 255.0, 1},       // 3
    Vector4.{160 / 255.0, 91 / 255.0, 118 / 255.0, 1},      // 4
    Vector4.{215 / 255.0, 118 / 255.0, 107 / 255.0, 1},     // 5
    Vector4.{225 / 255.0, 178 / 255.0, 140 / 255.0, 1},     // 6
    Vector4.{222 / 255.0, 231 / 255.0, 173 / 255.0, 1},     // 7
    ];

SpriteType :: enum u8 {
    NONE;
    WALL;
    WALL_EDGE;
    GROUND;
    PLAYER;
    CRATE;
    CRATE_SLOT;
}

SpriteIndex :: struct {
    x : int;
    y : int;
}

sprites : [64] SpriteIndex;

sprite_get_index :: (spr :SpriteType) -> SpriteIndex {
    si : SpriteIndex = sprites[cast (int) spr];
    return si;
}

set_sprite :: (type : SpriteType, cx: int, cy: int) {
    sprites[cast (int) type].x = cx;
    sprites[cast (int) type].y = cy;
}

assets_init :: () {
    set_sprite(.NONE, 10, 10);

    set_sprite(.WALL, 0, 0);
    set_sprite(.WALL_EDGE, 0, 1);
    set_sprite(.GROUND, 10, 10);
    set_sprite(.PLAYER, 1, 0);
    set_sprite(.CRATE, 2, 0);
    set_sprite(.CRATE_SLOT, 3, 0);
}
