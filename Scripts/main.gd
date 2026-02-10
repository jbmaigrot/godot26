extends Node2D
class_name Main

@export var max_health: int = 20
@onready var base_health: int = max_health # On initialise avec le max
@export var game_over_screen: Control


var gold: float = 70.0
var wood: float = 40.0
var stone: float = 0.0

var wood_per_second: float = 0.0
var stone_per_second: float = 0.0

@onready var ui = %UI_resources
@onready var resources_manager = %Resources 

var total_kills: int = 0
var game_time: float = 0.0
var is_game_over: bool = false # Flag pour stopper la logique


@export_group("Visual Effects")
@export var floating_value_scene: PackedScene
@export var heart_icon: Texture2D # Glisse ton icône de coeur ici
@export var base_node: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if game_over_screen:
		game_over_screen.hide() # On s'assure qu'il est caché au début
	# connect le bouton UI sur la possibilité de creer des tours
	%UI.global_add_tower_request.connect(%Towers._on_ui_add_tower_request)
	# 2. Connexion au ResourcesManager
	if resources_manager:
		resources_manager.production_changed.connect(_on_production_rates_changed)
		# On force une première mise à jour pour initialiser les valeurs
		resources_manager.update_totals()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_game_over:
		return
	
	# Accumulation précise avec delta
	wood += wood_per_second * delta
	stone += stone_per_second * delta
	game_time += delta
	update_ui_elements()

# Cette fonction reçoit les nouvelles valeurs dès qu'un masque change
func _on_production_rates_changed(new_wood_ps: float, new_stone_ps: float) -> void:
	wood_per_second = new_wood_ps
	stone_per_second = new_stone_ps
	# Optionnel : update_ui_elements() ici si tu veux un retour immédiat sur l'UI

func take_damage(amount: int):
	if is_game_over: return
	base_health -= amount

	spawn_base_damage_visual(amount)
	print("Base hit! Health remaining: ", base_health)
	update_ui_elements()
	if base_health <= 0:
		base_health = 0 # Propreté pour l'UI
		game_over()

func spawn_base_damage_visual(amount: int):
	if floating_value_scene:
		var damage_popup = floating_value_scene.instantiate()
		
		# On place le popup sur la base avec un décalage vertical
		damage_popup.global_position = base_node.global_position 
		
		get_tree().current_scene.add_child(damage_popup)
		
		# On affiche "-X" pour les dégâts
		damage_popup.setup(-amount, heart_icon, Color.RED)

func game_over():
	is_game_over = true
	print("Game Over!")

	# Rendre l'UI visible
	if game_over_screen:
		game_over_screen.show()
	
	# Optionnel : Arrêter le reste du monde (physique, ennemis, etc.)
	get_tree().paused = true 
	# (Attention : si tu utilises paused = true, ton UI de Game Over 
	# doit avoir son Process Mode réglé sur "Always" pour rester cliquable)
	
	
func check_tower_money(tower_info: TowerData) -> bool:
	# Vérification avec les bons noms de variables du TowerData
	if gold >= tower_info.cost_gold and wood >= tower_info.cost_wood and stone >= tower_info.cost_stone:
		# Déduction des ressources
		gold -= tower_info.cost_gold
		wood -= tower_info.cost_wood
		stone -= tower_info.cost_stone
		
		update_ui_elements()
		return true
	
	print("Ressources insuffisantes pour : ", tower_info.name)
	return false
	
func update_ui_elements() -> void:
	if ui:
		ui.update_gold(int(gold))
		ui.update_wood(int(wood), int(wood_per_second))
		ui.update_stone(int(stone), int(stone_per_second))
		# --- APPEL DES NOUVELLES FONCTIONS UI ---
		ui.update_kills(total_kills)
		ui.update_timer(int(game_time))
		ui.update_health(base_health, max_health)


func add_money(value: int):
	if is_game_over: return
	gold += value
	total_kills += 1 # Chaque gain d'argent (loot) compte comme un kill
