extends Control


func _input(event: InputEvent) -> void:
	# Vérifie si la touche R est pressée
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_R and event.pressed):
		restart_game()

func restart_game() -> void:
	print("Relance du jeu...")
	# Recharge la scène active depuis le début
	get_tree().paused = false 
	get_tree().reload_current_scene()
