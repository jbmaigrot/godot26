extends TextureButton

# 1. On déclare le signal personnalisé
signal add_tower_request(is_active: bool)

var ghost_enabled: bool = false

func _ready() -> void:
	# On connecte le signal interne de Godot à notre propre logique
	self.pressed.connect(_on_self_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		ghost_enabled = false
		add_tower_request.emit(ghost_enabled)

func _on_self_pressed() -> void:
	ghost_enabled = !ghost_enabled # On inverse l'état (ON/OFF)
	
	# 2. On émet notre signal avec l'état actuel
	add_tower_request.emit(ghost_enabled)
	
	print("Signal Ghost émis ! État : ", ghost_enabled)
