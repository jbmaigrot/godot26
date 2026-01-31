extends Node2D
class_name Main


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect le bouton UI sur la possibilité de creer des tours
	$UI.add_tower_request.connect($Towers._on_ui_add_tower_request)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
