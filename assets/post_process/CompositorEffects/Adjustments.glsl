#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;

layout(push_constant, std430) uniform Params {
    float brightness;
    float saturation;
} p;

void main() {
    ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);

    ivec2 size = imageSize(screen_tex);
    if (pixel.x >= size.x || pixel.y >= size.y)
        return;

    vec4 color = imageLoad(screen_tex, pixel);

    float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    color.rgb = mix(vec3(luminance), color.rgb, p.saturation);
    color.rgb *= p.brightness;

    imageStore(screen_tex, pixel, color);
}