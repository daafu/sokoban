#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Simp";
#import "GL";

// https://lospec.com/palette-list/purplemorning8
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

SpriteIndex :: struct {
    x : u16;
    y : u16;
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

SpriteFont :: struct {
    first_char : u8;
    glyph_width : int;
    glyph_height : int;
    spacing_x : int;
    spacing_y : int;
    space_width: int;
    glyphs: [..] Rect;    
}

sprites : [64] SpriteIndex;
sprite_fill_corners : [16] SpriteIndex;
sprite_fill_sides : [16] SpriteIndex;
sprite_title_art : Rect;
sprite_title_text1 : Rect;
sprite_title_text2 : Rect;
sprite_slider_tag : Rect;
sprite_slider_bar : Rect;
sprite_checkbox_off : Rect;
sprite_checkbox_on : Rect;

sprite_logo : Rect;

sprite_help1 : Rect;
sprite_help2 : Rect;

font_expire : SpriteFont;

arts : Simp.Texture;
logo : Simp.Texture;

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

shader_present : Shader;

sprite_get_index :: (spr :SpriteType) -> SpriteIndex {
    si : SpriteIndex = sprites[cast (int) spr];
    return si;
}

set_sprite :: (type : SpriteType, cx: int, cy: int) {
    sprites[cast (int) type].x = xx cx;
    sprites[cast (int) type].y = xx cy;
}

set_font :: (font : *SpriteFont, first_char: u8, last_char: u8, pos: Vector2i, col: int, glyph_width: int, glyph_height: int, spacing_x: int, spacing_y: int, space_width: int) {
    if font == null then return;

    font.first_char = first_char;
    font.glyph_width = glyph_width;
    font.glyph_height = glyph_height;
    font.spacing_x = spacing_x;
    font.spacing_y = spacing_y;
    font.space_width = space_width;
    
    char_count := cast(int) last_char - cast(int)first_char + 1;

    array_reset(*font.glyphs);

    glyph_x := pos.x;
    glyph_y := pos.y;
    glyph_col := 0;

    for i: 0..(char_count - 1) {
        if i != 0 && i % col == 0 {
            glyph_x = pos.x;
            glyph_y += xx glyph_height;
        }

        glyph_rect : Rect;
        glyph_rect.x = glyph_x;
        glyph_rect.y = glyph_y;
        glyph_rect.width = xx glyph_width;
        glyph_rect.height = xx glyph_height;

        array_add(*font.glyphs, glyph_rect);

        glyph_x += xx glyph_width;
    }
}

assets_init :: () {
    Simp.texture_load_from_file(*arts, "res/arts.png");
    Simp.texture_load_from_file(*logo, "res/logo_trans.png");

    set_sprite(.NONE, U16_MAX, U16_MAX);

    set_sprite(.WALL, 0, 0);
    set_sprite(.WALL_EDGE, 0, 1);
    set_sprite(.GROUND, 0, 10);
    set_sprite(.PLAYER, 1, 0);
    set_sprite(.CRATE, 2, 0);
    set_sprite(.CRATE_SLOT, 3, 0);
    set_sprite(.DOOR_CLOSED, 0, 2);
    set_sprite(.DOOR_OPEN, 0, 3);

    set_sprite(.UI_HAND, 16, 6);
    set_sprite(.FADE_IN_SLANT, 17, 6);
    set_sprite(.FADE_SOLID, 18, 6);
    set_sprite(.FADE_OUT_SLANT, 19, 6);

    set_sprite(.GRASS1, 4, 0);
    set_sprite(.GRASS2, 5, 0);
    set_sprite(.GRASS3, 6, 0);
    set_sprite(.GRASS4, 7, 0);
    set_sprite(.GRASS5, 8, 0);
    set_sprite(.GRASS6, 9, 0);
    set_sprite(.GRASS7, 10, 0);
    set_sprite(.GRASS8, 11, 0);
    set_sprite(.GRASS9, 12, 0);
    set_sprite(.GRASS10, 13, 0);

    for v, i : sprite_fill_corners {
        sprite_fill_corners[i].x = 0;
        sprite_fill_corners[i].y = 6;
    }

    for v, i : sprite_fill_sides {
        sprite_fill_sides[i].x = 0;
        sprite_fill_sides[i].y = 7;
    }

    sprite_fill_corners[0b0000].x = 0;
    sprite_fill_corners[0b0001].x = 1;
    sprite_fill_corners[0b0010].x = 2;
    sprite_fill_corners[0b0011].x = 3;
    sprite_fill_corners[0b0100].x = 4;
    sprite_fill_corners[0b0101].x = 5;
    sprite_fill_corners[0b0110].x = 6;
    sprite_fill_corners[0b0111].x = 7;
    sprite_fill_corners[0b1000].x = 8;
    sprite_fill_corners[0b1001].x = 9;
    sprite_fill_corners[0b1010].x = 10;
    sprite_fill_corners[0b1011].x = 11;
    sprite_fill_corners[0b1100].x = 12;
    sprite_fill_corners[0b1101].x = 13;
    sprite_fill_corners[0b1110].x = 14;
    sprite_fill_corners[0b1111].x = 15;

    sprite_fill_sides[0b0000].x = 0;
    sprite_fill_sides[0b0001].x = 1;
    sprite_fill_sides[0b0010].x = 2;
    sprite_fill_sides[0b0011].x = 3;
    sprite_fill_sides[0b0100].x = 4;
    sprite_fill_sides[0b0101].x = 5;
    sprite_fill_sides[0b0110].x = 6;
    sprite_fill_sides[0b0111].x = 7;
    sprite_fill_sides[0b1000].x = 8;
    sprite_fill_sides[0b1001].x = 9;
    sprite_fill_sides[0b1010].x = 10;
    sprite_fill_sides[0b1011].x = 11;
    sprite_fill_sides[0b1100].x = 12;
    sprite_fill_sides[0b1101].x = 13;
    sprite_fill_sides[0b1110].x = 14;
    sprite_fill_sides[0b1111].x = 15;

    sprite_title_art = Rect.{0, 140, 463, 338};
    sprite_title_text1 = Rect.{236, 0, 276, 56};
    sprite_title_text2 = Rect.{306, 56, 206, 38};

    sprite_slider_tag = Rect.{256, 116, 5, 8};
    sprite_slider_bar = Rect.{262, 116, 23, 8};
    sprite_checkbox_off = Rect.{288, 115, 10, 10};
    sprite_checkbox_on = Rect.{304, 115, 10, 10};

    sprite_help1 = Rect.{320, 96, 44, 13};
    sprite_help2 = Rect.{320, 112, 55, 15};

    sprite_logo = Rect.{0, 0, 1024, 1024};

    set_font(*font_expire, #char "!", #char "z", .{0, 485}, 32, 9, 9, -1, 0, 6);

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

    shader_present.gl_handle   = get_shader_program(SHADER_PRESENT);
    shader_present.alpha_blend = false;
}

#scope_file

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
