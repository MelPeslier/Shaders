shader_type canvas_item;

uniform float template_custom_debug : hint_range(0.0, 1.0, 0.5);

group_uniforms world;
uniform float tex_tiling = 1.0;
uniform vec2 tex_size = vec2(128.0);

group_uniforms template;

group_uniforms custom;
uniform vec4 color : source_color = vec4(0.0,0.0,0.0,1.0);
uniform sampler2D custom_main_s : hint_default_black, repeat_enable;

group_uniforms debug;


group_uniforms BackBuffer;
uniform vec2 camera_zoom = vec2(1.0);
uniform sampler2D back_buffer_textures : hint_screen_texture;

varying vec2 world_pos; // Keep the variable for the fragment shader

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy; // Get world position
}

void fragment() {
	vec2 tex_uv = tex_tiling / tex_size; // Define the uv size and stretch
	vec2 world_uv = tex_uv * world_pos; // Apply size to world position to get world_uv

	// *** CUSTOM ***
	vec4 custom_main_tex = texture(custom_main_s, world_uv);
	vec4 custom_final_tex = custom_main_tex;

	// *** TEMPLATE ***
	vec4 template_final_tex = custom_main_tex * 3.0;

	// *** DEBUG ***
	vec2 debug_uv = vec2( mod(world_uv.r, 1.0), mod(world_uv.g, 1.0) );

	vec4 debug_final_tex = vec4( debug_uv, 0.0, 1.0);

	vec4 back_buffer_tex = texture(back_buffer_textures, SCREEN_UV);
	//debug_final_tex.rgb = vec3 (back_buffer_coef) ;
	debug_final_tex = mix(debug_final_tex, back_buffer_tex, step(0.5, back_buffer_tex.r) ) ;



	// To switch from the different textures
	vec4 template_custom = mix(custom_final_tex, template_final_tex, step(0.25, template_custom_debug) ); // choose between template and custom
	vec4 final_tex = mix(template_custom, debug_final_tex, step(0.75, template_custom_debug) ); // choose between 2 previous result and debug
	COLOR = final_tex;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
