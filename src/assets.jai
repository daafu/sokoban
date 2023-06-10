#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Simp";
#import "GL";

CELL_WIDTH :: 16;
CELL_HEIGHT :: 16;

// https://lospec.com/palette-list/purplemorning8
pal : [8] Colorf : Colorf.[
    Colorf.{12 / 255.0, 7 / 255.0, 40 / 255.0, 1},         // 0
    Colorf.{28 / 255.0, 23 / 255.0, 68 / 255.0, 1},        // 1
    Colorf.{44 / 255.0, 50 / 255.0, 87 / 255.0, 1},        // 2
    Colorf.{89 / 255.0, 76 / 255.0, 106 / 255.0, 1},       // 3
    Colorf.{160 / 255.0, 91 / 255.0, 118 / 255.0, 1},      // 4
    Colorf.{215 / 255.0, 118 / 255.0, 107 / 255.0, 1},     // 5
    Colorf.{225 / 255.0, 178 / 255.0, 140 / 255.0, 1},     // 6
    Colorf.{222 / 255.0, 231 / 255.0, 173 / 255.0, 1},     // 7
    ];

SpriteType :: enum u8 {
    NONE;
    WALL;
    WALL_EDGE;
    GROUND;
    PLAYER;
    CRATE;
    CRATE_SLOT;
    DOOR_CLOSED;
    DOOR_OPEN;
    UI_HAND;
    FADE_IN_SLANT;
    FADE_OUT_SLANT;
    FADE_SOLID;
    GRASS1;
    GRASS2;
    GRASS3;
    GRASS4;
    GRASS5;
    GRASS6;
    GRASS7;
    GRASS8;
    GRASS9;
    GRASS10;
}

Rect :: struct {
    x: s32;
    y: s32;
    width: s32;
    height: s32;
}

Vector2i :: struct {
    x: s32;
    y: s32;
}

sprite_pack : *Asset;
logo : *Asset;

sprites : [64] PackedSprite;
sprite_fill_corners : [16] PackedSprite;
sprite_fill_sides : [16] PackedSprite;
sprite_title_art : PackedSprite;
sprite_title_text1 : PackedSprite;
sprite_title_text2 : PackedSprite;
sprite_slider_tag : PackedSprite;
sprite_slider_bar : PackedSprite;
sprite_checkbox_off : PackedSprite;
sprite_checkbox_on : PackedSprite;

sprite_help1 : PackedSprite;
sprite_help2 : PackedSprite;

sprite_logo : Rect;

font_expire : *Asset;


sound_step : *Mixer_Sound_Data;
sound_push : *Mixer_Sound_Data;
sound_option : *Mixer_Sound_Data;
sound_select : *Mixer_Sound_Data;
sound_cancel : *Mixer_Sound_Data;
sound_door_open : *Mixer_Sound_Data;
sound_door_close : *Mixer_Sound_Data;
sound_win : *Mixer_Sound_Data;
sound_scene_swish : *Mixer_Sound_Data;
sound_drawer_open : *Mixer_Sound_Data;
sound_drawer_snap : *Mixer_Sound_Data;

shader_present : *Asset;

sprite_get_index :: (spr :SpriteType) -> PackedSprite {
    si : PackedSprite = sprites[cast (int) spr];
    return si;
}

set_sprite :: (type : SpriteType, name: string) {
    sprites[cast (int) type] = asset_get_sprite(sprite_pack, name.data);
}

assets_init :: () {
    logo = asset_load("images/logo_trans.png");
    sprite_pack = asset_load("spritepack/spritepack.sp");

    set_sprite(.WALL, "wall_top.png");
    set_sprite(.WALL_EDGE, "wall_side.png");
    set_sprite(.GROUND, "ground.png");
    set_sprite(.PLAYER, "player_0.png");
    set_sprite(.CRATE, "crate.png");
    set_sprite(.CRATE_SLOT, "crate_slot.png");
    set_sprite(.DOOR_CLOSED, "door_closed.png");
    set_sprite(.DOOR_OPEN, "door_open.png");

    set_sprite(.UI_HAND, "ui_hand.png");
    set_sprite(.FADE_IN_SLANT, "transition_angle_0.png");
    set_sprite(.FADE_SOLID, "transition_fill.png");
    set_sprite(.FADE_OUT_SLANT, "transition_angle_1.png");

    set_sprite(.GRASS1, "grass_0.png");
    set_sprite(.GRASS2, "grass_1.png");
    set_sprite(.GRASS3, "grass_2.png");
    set_sprite(.GRASS4, "grass_3.png");
    set_sprite(.GRASS5, "grass_4.png");
    set_sprite(.GRASS6, "grass_5.png");
    set_sprite(.GRASS7, "grass_6.png");
    set_sprite(.GRASS8, "grass_7.png");
    set_sprite(.GRASS9, "grass_8.png");
    set_sprite(.GRASS10, "grass_9.png");

    sprite_fill_corners[0b0000] = asset_get_sprite(sprite_pack, "fill_corner_0.png");
    sprite_fill_corners[0b0001] = asset_get_sprite(sprite_pack, "fill_corner_1.png");
    sprite_fill_corners[0b0010] = asset_get_sprite(sprite_pack, "fill_corner_2.png");
    sprite_fill_corners[0b0011] = asset_get_sprite(sprite_pack, "fill_corner_3.png");
    sprite_fill_corners[0b0100] = asset_get_sprite(sprite_pack, "fill_corner_4.png");
    sprite_fill_corners[0b0101] = asset_get_sprite(sprite_pack, "fill_corner_5.png");
    sprite_fill_corners[0b0110] = asset_get_sprite(sprite_pack, "fill_corner_6.png");
    sprite_fill_corners[0b0111] = asset_get_sprite(sprite_pack, "fill_corner_7.png");
    sprite_fill_corners[0b1000] = asset_get_sprite(sprite_pack, "fill_corner_8.png");
    sprite_fill_corners[0b1001] = asset_get_sprite(sprite_pack, "fill_corner_9.png");
    sprite_fill_corners[0b1010] = asset_get_sprite(sprite_pack, "fill_corner_10.png");
    sprite_fill_corners[0b1011] = asset_get_sprite(sprite_pack, "fill_corner_11.png");
    sprite_fill_corners[0b1100] = asset_get_sprite(sprite_pack, "fill_corner_12.png");
    sprite_fill_corners[0b1101] = asset_get_sprite(sprite_pack, "fill_corner_13.png");
    sprite_fill_corners[0b1110] = asset_get_sprite(sprite_pack, "fill_corner_14.png");
    sprite_fill_corners[0b1111] = asset_get_sprite(sprite_pack, "fill_corner_15.png");

    sprite_fill_sides[0b0000] = asset_get_sprite(sprite_pack, "fill_side_0.png");
    sprite_fill_sides[0b0001] = asset_get_sprite(sprite_pack, "fill_side_1.png");
    sprite_fill_sides[0b0010] = asset_get_sprite(sprite_pack, "fill_side_2.png");
    sprite_fill_sides[0b0011] = asset_get_sprite(sprite_pack, "fill_side_3.png");
    sprite_fill_sides[0b0100] = asset_get_sprite(sprite_pack, "fill_side_4.png");
    sprite_fill_sides[0b0101] = asset_get_sprite(sprite_pack, "fill_side_5.png");
    sprite_fill_sides[0b0110] = asset_get_sprite(sprite_pack, "fill_side_6.png");
    sprite_fill_sides[0b0111] = asset_get_sprite(sprite_pack, "fill_side_7.png");
    sprite_fill_sides[0b1000] = asset_get_sprite(sprite_pack, "fill_side_8.png");
    sprite_fill_sides[0b1001] = asset_get_sprite(sprite_pack, "fill_side_9.png");
    sprite_fill_sides[0b1010] = asset_get_sprite(sprite_pack, "fill_side_10.png");
    sprite_fill_sides[0b1011] = asset_get_sprite(sprite_pack, "fill_side_11.png");
    sprite_fill_sides[0b1100] = asset_get_sprite(sprite_pack, "fill_side_12.png");
    sprite_fill_sides[0b1101] = asset_get_sprite(sprite_pack, "fill_side_13.png");
    sprite_fill_sides[0b1110] = asset_get_sprite(sprite_pack, "fill_side_14.png");
    sprite_fill_sides[0b1111] = asset_get_sprite(sprite_pack, "fill_side_15.png");

    sprite_title_art = asset_get_sprite(sprite_pack, "ui_tilte_art.png");
    sprite_title_text1 = asset_get_sprite(sprite_pack, "ui_title_0.png");
    sprite_title_text2 = asset_get_sprite(sprite_pack, "ui_title_1.png");

    sprite_slider_tag = asset_get_sprite(sprite_pack, "ui_slider_handle.png");
    sprite_slider_bar = asset_get_sprite(sprite_pack, "ui_slider.png");
    sprite_checkbox_off = asset_get_sprite(sprite_pack, "ui_unchecked.png");
    sprite_checkbox_on = asset_get_sprite(sprite_pack, "ui_checked.png");

    sprite_help1 = asset_get_sprite(sprite_pack, "help_rules.png");
    sprite_help2 = asset_get_sprite(sprite_pack, "help_reset.png");

    sprite_logo = Rect.{0, 0, 1024, 1024};

    font_expire = null;
    //set_font(*font_expire, #char "!", #char "z", .{0, 485}, 32, 9, 9, -1, 0, 6);

    sound_step = audio_load("res/footstep.wav");
    sound_push = audio_load("res/push.wav");
    sound_option = audio_load("res/option.wav");
    sound_select = audio_load("res/select.wav");
    sound_cancel = audio_load("res/cancel.wav");
    sound_door_open = audio_load("res/door_open.wav");
    sound_door_close = audio_load("res/door_close.wav");
    sound_win = audio_load("res/level_done.wav");
    sound_scene_swish = audio_load("res/swish.wav");
    sound_drawer_open = audio_load("res/drawer_open.wav");
    sound_drawer_snap = audio_load("res/drawer_snap.wav");

//    shader_present.gl_handle   = get_shader_program(SHADER_PRESENT);
//    shader_present.alpha_blend = false;
}

#scope_file

// This function is extracted from Simp module which current doesn't expose shader compilation
get_shader_program :: (shader_text: string) -> GLuint {
    LOG_BUFFER_SIZE :: 512;

    make_shader_object :: (shader: string, prefix: string, shader_type : GLenum) -> GLuint {
        shader_object := glCreateShader(shader_type);

        //shader_str := temp_c_string(shader);
        shaders: [2] *u8;
        lengths: [2] s32;

        shaders[0] = prefix.data;
        shaders[1] = shader.data;
        lengths[0] = xx prefix.count;
        lengths[1] = xx shader.count;

        glShaderSource(shader_object, 2, shaders.data, lengths.data);

        glCompileShader(shader_object);

        success : GLint;
        glGetShaderiv(shader_object, GL_COMPILE_STATUS, *success);

        if !success then {
            log_data: [LOG_BUFFER_SIZE] u8;
            glGetShaderInfoLog(shader_object, log_data.count, null, log_data.data);
            log("%", to_string(log_data.data), flags=.ERROR);
            return 0;
        }

        return shader_object;
    }

    PREFIX_V :: #string END
    #version 330 core
    #define VERTEX_SHADER
    #define OUT_IN out
    END

    PREFIX_F :: #string END
    #version 330 core
    #define FRAGMENT_SHADER
    #define OUT_IN in
    END

    shader_v := make_shader_object(shader_text, PREFIX_V, GL_VERTEX_SHADER);
    shader_f := make_shader_object(shader_text, PREFIX_F, GL_FRAGMENT_SHADER);
    shader_p := glCreateProgram();

    glAttachShader(shader_p, shader_v);
    glAttachShader(shader_p, shader_f);
    glLinkProgram(shader_p);

    success : GLint = 0;
    glGetProgramiv(shader_p, GL_LINK_STATUS, *success);

    if !success then {
        log_data: [LOG_BUFFER_SIZE] u8;
        glGetProgramInfoLog(shader_p, log_data.count, null, log_data.data);
        log("%", to_string(log_data.data), flags=.ERROR);
        return 0;
    }

    glDeleteShader(shader_v);
    glDeleteShader(shader_f);

    return shader_p;
}

SHADER_PRESENT :: #string END
OUT_IN vec2 TexCoords;
OUT_IN vec4 iterated_color;

#ifdef VERTEX_SHADER
in vec4 vert_position;
in vec4 vert_color;
in vec2 vert_uv0;

uniform mat4 projection;

void main() {
    TexCoords = vec2(vert_uv0.x, 1-vert_uv0.y);
    gl_Position = projection * vec4(vert_position.xy, 0.0, 1.0);
    iterated_color = vert_color;
}
#endif // VERTEX_SHADER

#ifdef FRAGMENT_SHADER
out vec4 out_color;

uniform sampler2D diffuse_texture;
uniform highp vec2 texture0Size;
uniform highp vec2 screenNativeSize;

void main () {
    vec2 uv = TexCoords;

    float sampleFactor = 1.0f / ((screenNativeSize.x / texture0Size.x) * 2.5f);
    float chromaticAberration = (screenNativeSize.x / 1500000.0) / (screenNativeSize.x / 1280.0);
    chromaticAberration = chromaticAberration * 0.5;

    /* Wrap UV */
    float warp_amount = 0.15;
    vec2 delta = uv - 0.5;
    float delta2 = dot(delta.xy, delta.xy);
    float delta4 = delta2 * delta2;
    float delta_offset = delta4 * warp_amount;

    uv = uv + delta * delta_offset;

    /* Here we sample neighbouring pixels to get some pixel smoothing when display size
    doesn't divide evenly into the native window resolution. */
    vec2 pixelSize = vec2(1.0 / texture0Size.x, 1.0 / texture0Size.y);
    pixelSize *= sampleFactor;

    mediump vec4 leftColor;
    leftColor.r = texture2D(diffuse_texture, vec2(uv.x - pixelSize.x, uv.y) + chromaticAberration).r;
    leftColor.ga = texture2D(diffuse_texture, vec2(uv.x - pixelSize.x, uv.y)).ga;
    leftColor.b = texture2D(diffuse_texture, vec2(uv.x - pixelSize.x, uv.y) - chromaticAberration).b;

    mediump vec4 rightColor;
    rightColor.r = texture2D(diffuse_texture, vec2(uv.x + pixelSize.x, uv.y) + chromaticAberration).r;
    rightColor.ga = texture2D(diffuse_texture, vec2(uv.x + pixelSize.x, uv.y)).ga;
    rightColor.b = texture2D(diffuse_texture, vec2(uv.x + pixelSize.x, uv.y) - chromaticAberration).b;

    mediump vec4 topColor;
    topColor.r = texture2D(diffuse_texture, vec2(uv.x, uv.y + pixelSize.y) + chromaticAberration).r;
    topColor.ga = texture2D(diffuse_texture, vec2(uv.x, uv.y + pixelSize.y)).ga;
    topColor.b = texture2D(diffuse_texture, vec2(uv.x, uv.y + pixelSize.y) - chromaticAberration).b;

    mediump vec4 bottomColor;
    bottomColor.r = texture2D(diffuse_texture, vec2(uv.x, uv.y - pixelSize.y) + chromaticAberration).r;
    bottomColor.ga = texture2D(diffuse_texture, vec2(uv.x, uv.y - pixelSize.y)).ga;
    bottomColor.b = texture2D(diffuse_texture, vec2(uv.x, uv.y - pixelSize.y) - chromaticAberration).b;

    vec4 texelColor = (leftColor + rightColor + topColor + bottomColor) / 4.0;

    vec4 color = texelColor * iterated_color;

    // Saturate
    float saturation = 0.15;
    vec4 scaledColor = color * vec4(0.3, 0.59, 0.11, 1);
    float luminance = scaledColor.r + scaledColor.g + scaledColor.b;
    vec4 desatColor = vec4(luminance, luminance, luminance, 1);
    color = mix(color, desatColor, -saturation);

    // Scanline
    float pixelLuminance = (color.r * 0.6) + (color.g * 0.3) + (color.b * 0.1) * 0.75;
    float scanWave = (sin((uv.y * texture0Size.y * 2.0) * 3.14159265) + 1.0) / 2.0;
    scanWave = (scanWave * scanWave);

    float scanlineIntensity = 0.5;
    float scanFade = 1.0 - ((scanWave) * scanlineIntensity * (1.0 - pixelLuminance));

    color *= scanFade;

    out_color = color;
}
#endif // FRAGMENT_SHADER
END
