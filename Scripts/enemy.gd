extends CharacterBody2D
class_name Enemy

@export var SPEED = 50.0
@export var target: Node2D = null # La base à atteindre

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	# On attend un peu que la map de navigation soit prête
	call_deferred("setup_navigation")

func setup_navigation():
	# Attendre la première frame physique pour s'assurer que le NavServer est synchronisé
	await get_tree().physics_frame
	if target:
		nav_agent.target_position = target.global_position

func _physics_process(_delta):
	if nav_agent.is_navigation_finished():
		return

	# Calcul de la direction vers le prochain point du chemin
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var current_agent_position: Vector2 = global_position
	
	# Calcul du vecteur de vélocité
	var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * SPEED
	
	# Application du mouvement
	velocity = new_velocity
	move_and_slide()

# Optionnel : Mettre à jour la cible si elle bouge (pas nécessaire pour une base fixe)
func update_target_position(new_target: Vector2):
	nav_agent.target_position = new_target
