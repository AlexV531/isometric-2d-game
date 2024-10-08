shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;

instance uniform float size = 1.0;
instance uniform float width = 0.2;
instance uniform vec4 color: source_color;

void fragment() {
	ALPHA = 0.0;
	vec2 uv = vec2(
		abs(UV.x - 0.5) * 2.0, 
		abs(UV.y - 0.5) * 2.0
	);
	float min_size = size - width;
	if ((uv.x > min_size || uv.y > min_size) && (uv.x < size && uv.y < size)) {
		ALPHA = color.a;
		ALBEDO = color.rgb;
	}
}
