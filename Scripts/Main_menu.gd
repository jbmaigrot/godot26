extends Node2D

# On utilise @export pour pouvoir glisser-déposer la scène 
# de ton jeu directement depuis l'inspecteur
@export_file("*.tscn") var game_scene_path: String

func _ready() -> void:
	# On s'assure que le jeu n'est pas en pause si on vient d'un Game Over
	get_tree().paused = false

func _on_play_button_pressed() -> void:
	if game_scene_path == "":
		print("Erreur : Le chemin de la scène n'est pas défini !")
		return
		
	# Change la scène vers le niveau principal
	get_tree().change_scene_to_file(game_scene_path)
