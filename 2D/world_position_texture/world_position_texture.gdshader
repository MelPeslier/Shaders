shader_type canvas_item;


const float EDGE_ZERO = 0.001;
const float EDGE_ONE = 0.999;


uniform float p_c_d : hint_range(0.0, 1.0, 0.5);
// __________ TODO ___ Use #if to reduce performance costs and not calculating other parts than the actual one ?


group_uniforms prototype;
uniform float p_tex_tiling = 1.0;
uniform vec2 p_tex_size = vec2(128.0);


group_uniforms custom_main;
uniform float c_tex_tiling = 1.0;
uniform vec2 c_tex_size = vec2(128.0);
uniform sampler2D c_main_sampler : hint_default_black, repeat_enable;
uniform sampler2D c_secondary_sampler : hint_default_black, repeat_enable;
uniform sampler2D c_mix_main_secondary_sampler : hint_default_black, repeat_enable; // Mixing the textures together depending on the texture (usually a noise)
uniform vec4 c_main_splats_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D c_mix_main_splats_sampler : hint_default_black, repeat_enable; // To mix some shadows splats or else to the texture
// Using noises and for the intensity of the color applied, just tweak the noise color ramp


group_uniforms custom_border_line;
uniform vec4 c_border_line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D c_mix_border_line_colors_sampler : hint_default_black, repeat_enable; // To mix some shadows splats or else to the texture
uniform vec4 c_border_line_splats_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);


group_uniforms custom_shadow;
uniform vec4 c_shadow_color : source_color = vec4(0.0, 0.0, 0.24, 1.0);


group_uniforms custom_shadow_line;
uniform vec4 c_shadow_line_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);


//group_uniforms debug;


group_uniforms BackBuffer;
uniform sampler2D back_buffer_s : hint_screen_texture;


varying vec2 world_pos; // Keep the variable for the fragment shader


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy; // Get world position
}


void fragment() {

// *** PROTOTYPE ***
	vec2 p_tex_uv = p_tex_tiling / p_tex_size; // Define the uv size and stretch
	vec2 p_world_uv = p_tex_uv * world_pos; // Apply size to world position to get world_uv
	vec4 p_main_tex = texture(c_main_sampler, p_world_uv);
	// ... TODO ! _____ Simple texture ans borders ? and shadow lines ? _____________ TODO _____________
	//vec2 d_uv = vec2( mod(world_uv.r, 1.0), mod(world_uv.g, 1.0) ); // UV to make tiles of 1
	vec4 p_final_tex = p_main_tex ;
// *** _____ ***


// *** CUSTOM ***
	vec2 c_tex_uv = p_tex_tiling / p_tex_size; // Define the uv size and stretch
	vec2 c_world_uv = c_tex_uv * world_pos; // Apply size to world position to get world_uv
	vec4 c_original_tex = texture(TEXTURE, UV);
	vec4 c_final_tex = vec4( vec3(0.0), c_original_tex.a);

// * Border line * : BLACK
	float c_is_black = step(c_original_tex.r, EDGE_ZERO) * step(c_original_tex.g, EDGE_ZERO) * step(c_original_tex.b, EDGE_ZERO);
	float c_border_line_splats_coef = texture(c_mix_border_line_colors_sampler, c_world_uv).r;
	vec4 c_border_line_tex = mix(c_border_line_color, c_border_line_splats_color, c_border_line_splats_coef);
	c_final_tex.rgb = c_border_line_tex.rgb * c_is_black  ; // Add result to the final texture output

// * Main texture * : RED
	vec4 c_main_tex = texture(c_main_sampler, c_world_uv);

	// _____ TODO _____ make the uv  being different , no same shit texture  all the time, ad variations, in intensity and  positionning
	// _ Then add secondary texture
	vec4 c_secondary_tex = texture(c_secondary_sampler, c_world_uv);
	float c_mix_tex_coef = texture(c_mix_main_secondary_sampler, c_world_uv).r;
	c_main_tex = mix(c_main_tex, c_secondary_tex, c_mix_tex_coef);

	// _ Then add color splats
	float c_mix_main_color_splats = texture(c_mix_main_splats_sampler, c_world_uv).r;
	c_main_tex.rgb = mix(c_main_tex.rgb, c_main_splats_color.rgb, c_mix_main_color_splats);

	// _ Then map this result to the correct 'original texture', here red(255)
	c_final_tex.rgb = mix(c_final_tex.rgb, c_main_tex.rgb, c_original_tex.r); // Add result to the final texture output


// * Shadow * : BLUE
	// TODO __ add choice between color and texture to it
	c_final_tex.rgb = mix(c_final_tex.rgb, c_shadow_color.rgb, c_original_tex.b);

// * Shadow line * : GREEN
	// TODO __ add choice between color and texture to it
	vec4 c_shadow_line_tex = c_shadow_line_color * c_original_tex.g;
	c_final_tex.rgb = mix(c_final_tex.rgb, c_shadow_line_color.rgb, c_original_tex.g);

// * Mix outer elements from back buffer *
	// TODO ______________ Add variations ? like a noise and it makes it smoothly mix or not
	vec4 back_buffer_tex = texture(back_buffer_s, SCREEN_UV);
	float bb_is_black = step(back_buffer_tex.r, EDGE_ZERO) * step(back_buffer_tex.g, EDGE_ZERO) * step(back_buffer_tex.b, EDGE_ZERO);
	c_final_tex = mix(back_buffer_tex, c_final_tex, bb_is_black);
// *** _____ ***


// *** DEBUG ***
	vec4 d_final_tex = texture(TEXTURE, UV);
// *** _____ ***


	// To switch from the different textures
	vec4 p_c = mix(p_final_tex, c_final_tex, step(0.25, p_c_d) ); // choose between prototype and custom
	vec4 final_tex = mix(p_c, d_final_tex, step(0.75, p_c_d) ); // choose between 2 previous result and debug
	COLOR = final_tex;
}