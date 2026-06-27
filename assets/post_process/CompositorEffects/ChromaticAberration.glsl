#[compute]
#version 450
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;
layout(push_constant, std430) uniform Params {
	float aberration;
} p;

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = imageSize(screen_tex);
	
	// Читаем каналы с граничной проверкой
	vec4 orig = imageLoad(screen_tex, clamp(pixel, ivec2(0), size - 1));
	
	float r = imageLoad(screen_tex, clamp(pixel + ivec2(p.aberration, 0), ivec2(0), size - 1)).r;
	float g = orig.g;
	float b = imageLoad(screen_tex, clamp(pixel - ivec2(p.aberration, 0), ivec2(0), size - 1)).b;
	
	// Вариант 1: мягкое смешивание
	vec4 color = vec4(r, g, b, orig.a);
	color = mix(orig, color, 0.5);  // 50% оригинала, 50% aberration
	
	imageStore(screen_tex, pixel, color);
}