// outline.gdshader
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, skip_vertex_transform;

uniform sampler2D stencil;
uniform float width = 20.0;
uniform vec4 color : source_color = vec4(0.0, 1.0, 0.0, 1.0);

varying vec2 uv_offset;

const float UV_BIAS = 0.00087;

void vertex() {
	// neutralize scaling from the transform matrix.
	// this ensures the normals are scaled uniformally, even for stretched meshes
	mat4 noscale = MODELVIEW_MATRIX;
	noscale[0] = normalize(noscale[0]);
	noscale[1] = normalize(noscale[1]);
	noscale[2] = normalize(noscale[2]);

	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((noscale * vec4(NORMAL, 0.0)).xyz);
	vec4 a = vec4(VERTEX, 1.0);

	// inflate vertex by normal * width (adjusted for viewing distance)
	VERTEX += NORMAL * -VERTEX.z * width / 1000.0;
	vec4 b = vec4(VERTEX, 1.0);

	a *= PROJECTION_MATRIX;
	b *= PROJECTION_MATRIX;
	a /= a.w;
	b /= b.w;

	uv_offset = normalize(b.xy - a.xy);
}

void fragment() {
	ALBEDO = color.rgb;
	// stencil out the inside
	//ALPHA = float(!(texture(stencil, SCREEN_UV + uv_offset * UV_BIAS).r > 0.0));
}