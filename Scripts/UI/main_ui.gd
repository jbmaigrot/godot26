extends Control

# Ce signal sera connecté à ton script de construction (celui avec les TileMaps)
signal global_add_tower_request(index: int)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# Clic droit pour annuler
	if Input.is_action_just_pressed("right_click"): # Utiliser action_just_pressed pour éviter le spam
		global_add_tower_request.emit(-1)


func _on_texture_button_add_tower_request(index: int) -> void:
	global_add_tower_request.emit(index)
