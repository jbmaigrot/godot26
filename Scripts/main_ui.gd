extends Control

signal add_tower_request(is_active: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_add_tower_request(is_active: bool) -> void:
		add_tower_request.emit(is_active)
