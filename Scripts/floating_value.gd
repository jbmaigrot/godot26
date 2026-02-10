extends Node2D

@export var anim_player: AnimationPlayer
@export var label: Label
@export var texture_rect: TextureRect

func _ready():
	# On connecte le signal pour détruire l'objet à la fin
	if anim_player:
		anim_player.animation_finished.connect(_on_animation_finished)

func setup(value: int, icon_texture: Texture2D, color: Color):
	# 1. Texte (ex: +1 ou -5)
	var prefix = "+" if value > 0 else ""
	label.text = prefix + str(value)
	label.modulate = color
	
	# 2. Icône
	texture_rect.texture = icon_texture
	
	# 3. Lancement de ton animation spécifique
	if anim_player and anim_player.has_animation("floating_value_animation"):
		anim_player.play("floating_value_animation")
	else:
		push_warning("Animation 'floating_value_animation' introuvable !")
		queue_free()

func _on_animation_finished(_anim_name: String):
	# Nettoyage automatique
	queue_free()
