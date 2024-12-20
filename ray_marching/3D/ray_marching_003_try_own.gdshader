shader_type spatial;
render_mode unshaded;

const int NUMBER_OF_STEPS = 32;
const float MINIMUM_HIT_DISTANCE = 0.001;
const float MAXIMUM_TRACE_DISTANCE = 100.0;

// Include the sdf shapes you need
float sdSphere( vec3 p, float s )
{
	return length(p)-s;
}
// Create your world scene
// Return the sdfs and the operations you want to deal with them
// so the 'world' as sdf from the shapes. '0' at the shape borders, '-' inside and '+' outside
float map(vec3 p)
{
	vec3 sphere_pos = vec3(0.0);
	float sphere = sdSphere( p - sphere_pos, 1.0 );
	return sphere;
}

// Ray marching : return the closest point of the ray from the origin ( camera )
// and the scene, our "map".
//float ray_marching(vec3 ro, vec3 rd)
//{
	//float t = 0.0; // Total distance Traveled
	//for (int i; i < NUMBER_OF_STEPS; i++)
	//{
		//vec3 p = ro + rd * t; // Position sur le Ray
		//float d = map(p); // Current distance to the scene
		//t += d; // March the Ray
		//if (t < MINIMUM_HIT_DISTANCE || t > MAXIMUM_TRACE_DISTANCE) break; // Early break
	//}
	//return t;
//}


void fragment()
{
	vec2 uv = fract(UV * vec2(3.0, 2.0)) - 0.5;

	// Initialisation
	vec3 color = vec3( uv, .05);  // debug_color
	vec3 ro = vec3(0.0, 0.0, -3.0); // Ray origin // Camera posiiton
	vec3 rd = normalize(vec3(uv, 1.0)); // Ray direction // Camera direction to part of uv

	int _i = 0;
	vec3 col = vec3(0.0);
	// Ray marching
	float t = 0.0; // Total distance Traveled
	for (int i = 0; i < NUMBER_OF_STEPS; i++)
	{
		_i += i;
		vec3 p = ro + rd * t; // Position sur le Ray
		float d = map(p); // Current distance to the scene
		t += d; // March the Ray
		col = vec3( float(i) ) / 80.0;
		if (d < MINIMUM_HIT_DISTANCE || t > MAXIMUM_TRACE_DISTANCE) break; // Early break
    }
	//color = vec3( t * 0.2) / 80.0;
	color = col;

	ALBEDO = color;
}