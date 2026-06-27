#[compute]
#version 450
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;
layout(push_constant, std430) uniform Params {
	float pixel_size;
} p;

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	vec4 color = imageLoad(screen_tex, pixel);
	
	ivec2 block_center = (pixel / ivec2(p.pixel_size)) * ivec2(p.pixel_size) + ivec2(p.pixel_size) / 2;
	color = imageLoad(screen_tex, clamp(block_center, ivec2(0), imageSize(screen_tex) - 1));

	imageStore(screen_tex, pixel, color);
}