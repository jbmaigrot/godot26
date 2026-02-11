shader_type canvas_item;

uniform vec2 speed = vec2(0.03, 0.02);
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float frequency : hint_range(0.0, 20.0) = 10.0;
uniform vec4 water_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	// 1. Création d'une distorsion pour simuler des vagues
	vec2 uv = UV;
	uv.x += sin(uv.y * frequency + TIME) * distortion_strength;
	uv.y += cos(uv.x * frequency + TIME) * distortion_strength;
	
	// 2. Application du défilement (Scrolling)
	vec2 moving_uv = uv + (TIME * speed);
	
	// 3. Lecture de la texture avec les UV modifiés
	vec4 color = texture(TEXTURE, moving_uv);
	
	// 4. Application d'une teinte (optionnel) et de la couleur finale
	COLOR = color * water_tint;
	
	
	
	
}