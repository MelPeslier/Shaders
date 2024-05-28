shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.0,0.0,0.0,1.0);
uniform sampler2D main_s : hint_default_black, repeat_enable;


uniform float ratio = 1.0;
uniform float tiling = 1.0;
uniform vec2 tex_size = vec2(128.0);

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	world_pos.y *= ratio;
}

void fragment() {
	vec2 tex_uv = tiling / tex_size;

	vec2 world_uv = tex_uv * world_pos;
	vec4 main_tex = texture(main_s, world_uv);

	COLOR = main_tex;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
