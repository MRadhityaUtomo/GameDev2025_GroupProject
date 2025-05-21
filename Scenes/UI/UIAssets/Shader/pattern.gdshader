shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.1, 0.0); // Scroll only on X-axis
uniform float time_offset = 0.0;

void fragment() {
    vec2 uv_scroll = UV + vec2((TIME + time_offset) * scroll_speed.x, 0.0);
    COLOR = texture(TEXTURE, uv_scroll);
}
