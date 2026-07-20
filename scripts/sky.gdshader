shader_type canvas_item;

uniform float star_density = 0.01;
uniform float resolution = 300.0;
uniform vec4 sky_color : source_color = vec4(0.05, 0.05, 0.1, 1.0);
uniform vec4 star_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 pixelated_uv = floor(UV * resolution) / resolution;
    float rand = random(pixelated_uv);
    float is_star = step(1.0 - star_density, rand);
    
    COLOR = mix(sky_color, star_color, is_star);
}