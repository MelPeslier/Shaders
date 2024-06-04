shader_type canvas_item;

uniform float p_tex_tiling = 1;
uniform vec2 p_tex_size = vec2(512.0);
uniform sampler2D rotation_noise : repeat_enable;
// Must be the same texture, but return type to with distance 2sub
uniform sampler2D hide_rotation_noise_seams : repeat_enable;

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

varying vec2 world_pos; // Keep the variable for the fragment shader
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy; // Get world position
}


void fragment()
{
	vec2 p_tex_uv = p_tex_tiling / p_tex_size; // Define the uv size and stretch
	vec2 p_world_uv = p_tex_uv * world_pos; // Apply size to world position to get world_uv
	
	float world_cubes =  abs(floor( world_pos.x / p_tex_size.x ) * floor(world_pos.y / p_tex_size.y)) ;
	
	float rotation = PI * texture(rotation_noise, p_world_uv / 100.0).r;
	vec2 rotated_uv = rotate(p_world_uv, vec2(0.5), rotation );
	//vec2 rotated_uv_by_noise = rotate(p_world_uv, vec2(0.5), rotation );
	
	vec4 rotated_tex = texture(TEXTURE, rotated_uv);
	//vec4 rotated_tex = texture(TEXTURE, rotated_uv_by_noise);
	
	vec4 normal_tex = texture(TEXTURE, p_world_uv);
	float hide_seams = texture(hide_rotation_noise_seams, p_world_uv/ 100.0).r;
	vec4 rotated_smeams_hidden_tex = mix(rotated_tex, normal_tex, hide_seams);
	
	vec4 rotated_noise = texture(rotation_noise, rotated_uv);
	
	

	//COLOR = rotated_tex;
	//COLOR = normal_tex;
	//COLOR = rotated_smeams_hidden_tex;
	//COLOR.rgb = vec3(hide_seams);
	//COLOR.rgb = 

	//COLOR.rgb = vec3( rotation / PI ) ;
	//COLOR.rgb = vec3( world_cubes ) * 0.001 ;
	
}
