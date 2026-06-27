#[compute]
#version 450
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;
layout(push_constant, std430) uniform Params {
	float noise_strength;
	float time;
} p;

float random(vec3 uv) {
	return fract(sin(dot(uv, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	vec4 color = imageLoad(screen_tex, pixel);
	
	// Шум зависит от позиции И времени
	float noise = random(vec3(vec2(pixel) * 0.1, p.time)) * p.noise_strength;
	color.rgb += noise;
	
	imageStore(screen_tex, pixel, color);
}