#[compute]
#version 450
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;
layout(push_constant, std430) uniform Params {
	float levels;
} p;

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	vec4 color = imageLoad(screen_tex, pixel);  // Читаем оригинальный пиксель
	color.rgb = floor(color.rgb * float(p.levels)) / float(p.levels);
	
	imageStore(screen_tex, pixel, color);
}