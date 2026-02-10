shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0); // Blanc par défaut
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    // On mélange la couleur originale avec la couleur de flash
    // en gardant l'alpha (transparence) d'origine
    color.rgb = mix(color.rgb, flash_color.rgb, flash_modifier);
    COLOR = color;
}