extends Node2D
class_name Main
@export var base_health: int = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect le bouton UI sur la possibilité de creer des tours
	$UI.global_add_tower_request.connect($Towers._on_ui_add_tower_request)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func take_damage(amount: int):
	base_health -= amount
	print("Base hit! Health remaining: ", base_health)
	
	if base_health <= 0:
		game_over()

func game_over():
	print("Game Over!")
	# You can use get_tree().reload_current_scene() to restart
	
	
func check_tower_money(tower_info: TowerData):
	return true
