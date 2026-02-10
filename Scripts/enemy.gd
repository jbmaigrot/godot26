extends CharacterBody2D
class_name Enemy

@export var SPEED = 50.0
@export var target: Node2D = null # La base à atteindre
@export var health: int = 30
@export var dammage: int = 1
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var gold_value = 2
@export var floating_value_scene: PackedScene
@export var gold_icon: Texture2D # Glisse ton icône de pièce ici

var main:Main = null




func _ready():
	# On attend un peu que la map de navigation soit prête
	call_deferred("setup_navigation")
	main = get_tree().current_scene as Main

func setup_navigation():
	# Attendre la première frame physique pour s'assurer que le NavServer est synchronisé
	await get_tree().physics_frame
	
	#target = $"../Player_base"
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
	
	# Manual check for reaching the target
	if target and global_position.distance_to(target.global_position) < 10:
		reach_base()

# Optionnel : Mettre à jour la cible si elle bouge (pas nécessaire pour une base fixe)
func update_target_position(new_target: Vector2):
	nav_agent.target_position = new_target
	
	
func take_damage(amount: int):
	health -= amount
	# Optional: Add a visual flash or hit effect here
	if health <= 0:
		die()
		


func die():
	# 1. Création du visuel de gain de ressources
	spawn_loot_visual(gold_value, gold_icon)
	
	# 2. Logique de jeu (ajout de l'argent réel)
	if main:
		main.add_money(gold_value)
	
	# 3. Suppression de l'ennemi
	queue_free()

func spawn_loot_visual(amount: int, icon: Texture2D):
	if floating_value_scene:
		var loot_popup = floating_value_scene.instantiate()
		
		# On le place sur l'ennemi
		loot_popup.global_position = global_position
		
		# On l'ajoute à la racine pour qu'il ne disparaisse pas avec queue_free() de l'ennemi
		get_tree().current_scene.add_child(loot_popup)
		
		# On le configure (Jaune pour l'or par exemple)
		loot_popup.setup(amount, icon, Color.YELLOW)
	

func reach_base():
	# Check if the target (the base) has a method to lose healt
	if main != null:
		main.take_damage(dammage) # Or whatever damage the enemy deals
	
	# The enemy has done its job, remove it
	queue_free()
