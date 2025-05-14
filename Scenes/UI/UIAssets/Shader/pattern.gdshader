shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.1, 0.05); // Adjust speed
uniform float time_offset = 0.0;

void fragment() {
    vec2 uv_scroll = UV + (TIME + time_offset) * scroll_speed;
    COLOR = texture(TEXTURE, uv_scroll);
}
