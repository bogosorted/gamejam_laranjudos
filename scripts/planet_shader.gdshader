shader_type canvas_item;

uniform sampler2D noise_tex;
uniform float resolution = 32.0;
uniform float slices = 5.0;
uniform vec4 light_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 dark_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec2 pixelated_uv = floor(UV * resolution) / resolution;
    float noise = texture(noise_tex, pixelated_uv).r;
    float line_effect = floor(noise * slices) / slices;
    
    vec4 final_color = mix(light_color, dark_color, line_effect);
    final_color.a *= COLOR.a; 
    
    COLOR = final_color;
}