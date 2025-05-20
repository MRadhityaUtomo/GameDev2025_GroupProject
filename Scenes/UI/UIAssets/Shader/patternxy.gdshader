shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.1, 0.1);
uniform float time_offset = 0.0;

void fragment() {
    vec2 uv_scroll = UV + (TIME + time_offset) * scroll_speed;
    vec4 tex_color = texture(TEXTURE, uv_scroll);
    // Preserve RGB from texture, but apply modulate alpha only
    tex_color.a *= COLOR.a;
    COLOR = tex_color;
}
