#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "String";

CELL_WIDTH :: 16;
CELL_HEIGHT :: 16;

camera_x : int = 0;
camera_y : int = 0;

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

draw_copy :: (src_x: int, src_y: int, src_width: int, src_height: int, draw_pos: Vector2, color: Vector4) {
    pos : Vector2 = draw_pos;
    pos.x += camera_x;
    pos.y += camera_y;

    uv0 := Vector2.{cast(float) src_x / arts.width, (cast (float) arts.height - src_y) / cast (float) arts.height};
    Simp.immediate_quad(pos, Vector2.{pos.x + src_width, pos.y}, Vector2.{pos.x + src_width, pos.y + src_height}, Vector2.{pos.x, pos.y + src_height}, color,
                uv0,
                Vector2.{uv0.x + (cast(float) src_width / arts.width), uv0.y},
                Vector2.{uv0.x + (cast(float) src_width / arts.width), uv0.y - (cast(float) src_height / arts.height)},
                Vector2.{uv0.x, uv0.y - (cast(float) src_height / arts.height)}
                );
}

draw_text_internal :: (font : *SpriteFont, draw_pos : Vector2, color : Vector4, text: string, measure_only: bool) -> int, int {
    pos : Vector2 = draw_pos;
    pos.x += camera_x;
    pos.y += camera_y;

    pos_x := cast(int)draw_pos.x;
    pos_y := cast(int)draw_pos.y;
    
    total_width := 0;
    total_height := font.glyph_height + font.spacing_y;

    for i : 0..text.count - 1 {
        c := text[i];

        if c == #char "\n" {
            pos_y += font.glyph_height + font.spacing_y;
            total_height += font.glyph_height + font.spacing_y;
        }

        glyph_i: int = c - cast(int)font.first_char;

        // Glyph not valid, or maybe its a space? Skip a space width
        if glyph_i < 0 || glyph_i >= font.glyphs.count {
            pos_x += font.space_width + font.spacing_x;
            total_width += font.space_width + font.spacing_x;
            continue;
        }

        glyph := font.glyphs[glyph_i];

        if !measure_only {
            draw_copy(glyph.x, glyph.y, glyph.width, glyph.height, Vector2.{cast(float)pos_x, cast(float)pos_y}, color);
        }

        pos_x += font.glyph_width + font.spacing_x;
        total_width += font.glyph_width + font.spacing_x;        
    }

    return total_width, total_height;
}

draw_text :: (font : *SpriteFont, draw_pos : Vector2, color : Vector4, text: string) {
    draw_text_internal(font, draw_pos, color, text, false);
}

measure_text :: (font : *SpriteFont, draw_pos : Vector2, color : Vector4, text: string) -> int, int {
    width, height := draw_text_internal(font, draw_pos, color, text, true);

    return width, height;
}

camera_set :: (x: int, y: int) {
    camera_x = x;
    camera_y = y;
}

camera_reset :: () {
    camera_x = 0;
    camera_y = 0;
}
