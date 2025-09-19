shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_thickness : hint_range(0, 100, 1) = 1.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    bool is_outline_pixel = false;
    for (float thickness = 1.0; thickness <= outline_thickness; thickness += 1.0) {
        vec2 offset = TEXTURE_PIXEL_SIZE * thickness;
        
        vec4 color_1 = (UV.x + offset.x > 1.0) ? vec4(0.0) : texture(TEXTURE, UV + vec2( offset.x,  0.0));
        vec4 color_2 = (UV.x - offset.x < 0.0) ? vec4(0.0) : texture(TEXTURE, UV + vec2(-offset.x,  0.0));
        vec4 color_3 = (UV.y + offset.y > 1.0) ? vec4(0.0) : texture(TEXTURE, UV + vec2( 0.0,  offset.y));
        vec4 color_4 = (UV.y - offset.y < 0.0) ? vec4(0.0) : texture(TEXTURE, UV + vec2( 0.0, -offset.y));
        vec4 color_5 = (UV.x - offset.x < 0.0 || UV.y + offset.y > 1.0) ? vec4(0.0) : texture(TEXTURE, UV + vec2(-offset.x,  offset.y));
        vec4 color_6 = (UV.x - offset.x < 0.0 || UV.y - offset.y < 0.0) ? vec4(0.0) : texture(TEXTURE, UV + vec2(-offset.x, -offset.y));
        vec4 color_7 = (UV.x + offset.x > 1.0 || UV.y + offset.y > 1.0) ? vec4(0.0) : texture(TEXTURE, UV + vec2( offset.x,  offset.y));
        vec4 color_8 = (UV.x + offset.x > 1.0 || UV.y - offset.y < 0.0) ? vec4(0.0) : texture(TEXTURE, UV + vec2( offset.x, -offset.y));
        
        if (color.a > 0.5 &&
            (color_1.a < 0.5 || color_2.a < 0.5 || color_3.a < 0.5 || color_4.a < 0.5 ||
             color_5.a < 0.5 || color_6.a < 0.5 || color_7.a < 0.5 || color_8.a < 0.5)) {
            is_outline_pixel = true;
            break;
        }
    }
    
    if (is_outline_pixel) {
        COLOR = outline_color;
    }
}