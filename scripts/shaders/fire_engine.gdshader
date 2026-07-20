shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 color : source_color = vec4(1.0, 0.0, 0.0, 1.0); 

void fragment() {
    vec4 color_base = texture(TEXTURE, UV);
    vec4 applyed_color = color_base * color; 
    
    float base_in_0 = 1.0 - UV.y;
    float mask = smoothstep(min(intensity, 0.31), min(intensity, 0.31) - 0.3, base_in_0);
    
    mask *= sign(intensity); 
    
    COLOR = mix(color_base, applyed_color, mask * mask);
}