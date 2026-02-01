extends Node2D
class_name Main
@export var base_health: int = 20

var gold: float = 100.0
var wood: float = 0.0
var stone: float = 0.0

var wood_per_second: float = 0.0
var stone_per_second: float = 0.0

@onready var ui = %UI_resources
@onready var resources_manager = %Resources 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect le bouton UI sur la possibilité de creer des tours
	%UI.global_add_tower_request.connect(%Towers._on_ui_add_tower_request)
	# 2. Connexion au ResourcesManager
	if resources_manager:
		resources_manager.production_changed.connect(_on_production_rates_changed)
		# On force une première mise à jour pour initialiser les valeurs
		resources_manager.update_totals()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Accumulation précise avec delta
	wood += wood_per_second * delta
	stone += stone_per_second * delta
	
	update_ui_elements()

# Cette fonction reçoit les nouvelles valeurs dès qu'un masque change
func _on_production_rates_changed(new_wood_ps: float, new_stone_ps: float) -> void:
	wood_per_second = new_wood_ps
	stone_per_second = new_stone_ps
	# Optionnel : update_ui_elements() ici si tu veux un retour immédiat sur l'UI

func take_damage(amount: int):
	base_health -= amount
	print("Base hit! Health remaining: ", base_health)
	
	if base_health <= 0:
		game_over()

func game_over():
	print("Game Over!")
	# You can use get_tree().reload_current_scene() to restart
	
	
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
		# On convertit en int() seulement pour l'affichage
		ui.update_gold(int(gold))
		ui.update_wood(int(wood), int(wood_per_second))
		ui.update_stone(int(stone), int(stone_per_second))
