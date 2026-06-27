#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;

layout(push_constant, std430) uniform Params {
    float blur_radius;
    float blur_intensity;
} p;

void main() {
    ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = imageSize(screen_tex);

    if (pixel.x >= size.x || pixel.y >= size.y)
        return;

    vec4 color = imageLoad(screen_tex, pixel);

    if (p.blur_radius > 0.0) {
        int radius = int(p.blur_radius);

        vec4 sum = vec4(0.0);
        int samples = 0;

        for (int y = -radius; y <= radius; y++) {
            for (int x = -radius; x <= radius; x++) {
                ivec2 coord = clamp(pixel + ivec2(x, y), ivec2(0), size - ivec2(1));

                sum += imageLoad(screen_tex, coord);
                samples++;
            }
        }

        vec4 blurred = sum / float(samples);
        color = mix(color, blurred, p.blur_intensity);
    }

    imageStore(screen_tex, pixel, color);
}