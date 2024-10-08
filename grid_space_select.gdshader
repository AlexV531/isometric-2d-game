shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;

uniform float size = 1.0;
uniform float width = 0.2;
uniform vec4 color: source_color;

uniform float amplitude = 0.3;
uniform float frequency = 2.2;

void vertex() {
    //float phase = mod(TIME*frequency, PI/2.0); // Keep the phase within 0 to pi
    //float offset = 0.0;
    //if(phase <= PI/2.0) {
        //offset = abs(cos(phase + PI/2.0)*amplitude); // Apply the cosine and shift by pi to start at -1
    //}
    //VERTEX.y = offset;
	VERTEX.y = abs(cos(TIME * frequency) * amplitude);
}

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
