shader_type spatial;
render_mode unshaded;

// *** SDF ***
float sdBox( vec3 p, vec3 b )
{
	vec3 q = abs(p) - b;
return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdSphere( in vec3 p, in float s )
{
	return length(p)-s;
}


float sdOctahedron( vec3 p, float s)
{
	p = abs(p);
	return (p.x+p.y+p.z-s)*0.57735027;
}

// *** Unions ***
float opUnion( in float d1, in float d2 )
{
	return min(d1,d2);
}
float opSubtraction( in float d1, in float d2 )
{
	return max(-d1,d2);
}
float opIntersection( in float d1, in float d2 )
{
	return max(d1,d2);
}
float opXor(in float d1, in float d2 )
{
	return max(min(d1,d2),-max(d1,d2));
}

// *** Smooth Union ***

float opSmoothUnion( in float d1, in float d2, in float k )
{
	float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
	return mix( d2, d1, h ) - k*h*(1.0-h);
}

float opSmoothSubtraction( in float d1, in float d2, in float k )
{
	float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
	return mix( d2, -d1, h ) + k*h*(1.0-h);
}

float opSmoothIntersection( in float d1, in float d2, in float k )
{
	float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
	return mix( d2, d1, h ) + k*h*(1.0-h);
}

// *** Rotation & Scale
mat2 rot2D(in float angle)
{
	float s = sin(angle);
	float c = cos(angle);
	return mat2(vec2(c, -s), vec2(s, c));
}

vec3 rot3D(in vec3 p, in vec3 axis, in float angle) // Quaternion
{
	return mix(dot(axis, p) * axis, p, cos(angle))
		+ cross(axis, p) + sin(angle);
}

// *** Color Palette
// cosine based palette, 4 vec3 params
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
	return a + b*cos( 6.283185*(c*t+d) );
}


uniform vec3 col_a : source_color = vec3(0.5, 0.5, 0.5);
uniform vec3 col_b : source_color = vec3(0.5, 0.5, 0.5);
uniform vec3 col_c : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 col_d : source_color = vec3(0.263, 0.416, 0.557);
uniform float view_distance = 0.04;
uniform float i_coef = 0.005;
uniform float box_to_octa : hint_range(0.0, 1.0) = 0.0;

vec3 palette_shortcut( in float t)
{
	return palette(t, col_a, col_b, col_c, col_d);
}

// Variables
// Ray Marching
const int NUMBER_OF_STEPS = 32;
const float MINIMUM_HIT_DISTANCE = 0.001;
const float MAXIMUM_TRACE_DISTANCE = 100.0;

// Mouse for in shader camera movement
// Make a script that actualise it via gdscript, when clicking and then draging,
// it should add or remove from here
uniform vec3 camera = vec3(0.0, 0.0, -3.0);


// For in 3D scene, not for canvas like
//varying vec3 camera; //Local Camera position
//varying vec3 position; //Vertex Position

float map(in vec3 p)
{
	vec3 sphere_0_position =  p + vec3(sin(TIME) , 0.0, -1.0 + cos(TIME) * 2.0);
	float displacement = sin(5.0 * p.x) * sin(5.0 * p.y) * sin(5.0 * p.z) * 0.25;
	float sphere_0 = sdSphere(sphere_0_position, 0.5) + displacement;

	p.z  += TIME * 0.4;

	// Spacing
	vec3 q = vec3(0.0);
	q.xy = (fract(p.xy) - 0.5);
	q.z = mod(p.z, 0.25) - 0.125;

	q.xy *= rot2D(TIME);
	float box_0 = sdBox(q + vec3( 0.0, 0.0, 0.0 ), vec3(0.1));
	float octa_0 = sdOctahedron(q, 0.2);
	box_0 = mix(box_0, octa_0, box_to_octa);

	return box_0;
	//return opSmoothUnion(sphere_0, box_0, 2.0);
}

//void vertex() {
	//position = VERTEX;
	//camera = (inverse(MODELVIEW_MATRIX) * vec4(0,0,0,1)).xyz; //Camera Position in Local Space
//}

void fragment()
{
	vec2 uv = UV * 2.0 - 1.0;
	vec2 m = camera.xy;

	//vec3 ro = camera;
	//vec3 rd = normalize(position - ro);
	vec3 ro = vec3(0.0, 0.0, camera.z);
	vec3 rd = normalize( vec3(uv, 1.0) );

	// Vertical Camera movement
	ro.yz *= rot2D(-m.y);
	rd.yz *= rot2D(-m.y);

	// Horizontal Camera movement
	ro.xz *= rot2D(-m.x);
	rd.xz *= rot2D(-m.x);


	int _i = 0;
	vec3 color = vec3(0.0);
	// Ray marching
	float t = 0.0; // Total distance Traveled
	for (int i = 0; i < NUMBER_OF_STEPS; i++)
	{
		_i = i;
		vec3 p = ro + rd * t; // Position sur le Ray
		float d = map(p); // Current distance to the scene
		t += d; // March the Ray
		color = vec3( float(i) ) / 80.0;
		if (d < MINIMUM_HIT_DISTANCE || t > MAXIMUM_TRACE_DISTANCE) break; // Early break
    }
	color = palette_shortcut(t * view_distance + float(_i) * i_coef);

	ALBEDO = color;
}