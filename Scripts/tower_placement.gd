extends Node2D

@export_group("Configurations")

#@export var tower_scene: PackedScene 
var selected_tower_scene: PackedScene = null
#@export var available_towers: Array[PackedScene] = []
var preview_sprite: Sprite2D = null
#@export var available_preview_sprite: Array[PackedScene] = []
var current_tower_index: int = -1
@export var available_towers_data: Array[TowerData] = []


@export_group("Références")
@export var ground_layer: TileMapLayer 
var mask_layer: TileMapLayer 


@export_group("Apparence")
@export var color_valid: Color = Color(0, 1, 0, 0.5) 
@export var color_invalid: Color = Color(1, 0, 0, 0.5)
@export var color_no_resources: Color = Color(1, 0.5, 0, 0.5) 

@onready var resources_container = $"../Resources" # Le nœud qui contient tes blocs de bois/pierre


var occupied_cells: Dictionary = {}
var buildable_data_name: String = "buildable"
var is_ghost_active: bool = false
var off_screen_pos: Vector2 = Vector2(-10000, -10000) # Position de sécurité

var main:Main = null

func _ready() -> void:
	main = get_tree().current_scene as Main
	disable_ghost()
	
	# On attend une frame pour être certain que la liste des enfants de "Resources" est complète
	call_deferred("_register_initial_resources")
	
	# 1. On trouve le gestionnaire
	var manager = $"../Masks_manager" 
	if manager:
		# On s'abonne au changement de masque (si tu as créé le signal)
		# Ou on récupère simplement le masque actuel au début
		mask_layer = manager.current_mask
		
		# Optionnel : Connecter un signal pour mettre à jour automatiquement
		manager.mask_changed.connect(_on_mask_changed)
	_register_initial_resources()

func _process(_delta):
# On s'arrête si le ghost n'est pas actif ou si le sprite n'est pas encore créé
	if not is_ghost_active or not preview_sprite:
		return

	var mouse_pos = get_global_mouse_position()
	var tile_pos = ground_layer.local_to_map(ground_layer.to_local(mouse_pos))
	
	preview_sprite.global_position = ground_layer.map_to_local(tile_pos) # + Vector2(0, -16)
	
	var tower_info = available_towers_data[current_tower_index]
	var can_afford = main.has_enough_resources(tower_info)
	var can_place = can_build_at(tile_pos)
	
	if not can_place:
		# CAS 1 : Terrain bloqué (Priorité haute)
		preview_sprite.modulate = color_invalid
	elif not can_afford:
		# CAS 2 : Terrain libre mais pas assez de ressources
		preview_sprite.modulate = color_no_resources
	else:
		# CAS 3 : Tout est OK
		preview_sprite.modulate = color_valid
		if Input.is_action_just_pressed("left_click"):
			place_tower(tile_pos)


func can_build_at(tile_pos: Vector2i) -> bool:
	# 1. Vérifier si le terrain de base autorise la construction
	var tile_data = ground_layer.get_cell_tile_data(tile_pos)
	if not tile_data or not tile_data.get_custom_data(buildable_data_name):
		return false
	
	# 2. VÉRIFICATION DU MASK : Si une tile existe à cet endroit, on bloque
	# get_cell_source_id retourne -1 si la cellule est vide
	if mask_layer and mask_layer.get_cell_source_id(tile_pos) != -1:
		return false
	
	# 3. Vérifier si une tour est déjà présente
	if occupied_cells.has(tile_pos):
		return false
		
	return true

func place_tower(tile_pos: Vector2i):
	if occupied_cells.has(tile_pos): 
		return

	var tower_info = available_towers_data[current_tower_index]

	# On retire l'argent car le clic a été validé par le _process
	main.spend_resources(tower_info)

	# Création de la tour
	var new_tower = selected_tower_scene.instantiate()
	add_child(new_tower)
	new_tower.global_position = ground_layer.map_to_local(tile_pos)
	occupied_cells[tile_pos] = new_tower

	print("Tour ", tower_info.name, " construite !")

## Réactive le mode fantôme
func enable_ghost(index: int) -> void:
	if index < 0 or index >= available_towers_data.size():
		disable_ghost()
		return
	
	is_ghost_active = true
	current_tower_index = index # On mémorise l'index
	
	# On récupère les infos depuis l'objet TowerData
	var data = available_towers_data[index]
	selected_tower_scene = data.scene
	
	if preview_sprite:
		preview_sprite.queue_free()
	
	# On instancie le preview_scene défini dans la ressource
	if data.preview_scene:
		preview_sprite = data.preview_scene.instantiate() as Sprite2D
		add_child(preview_sprite)
		preview_sprite.modulate = color_invalid
	print("Ghost activé pour la tour index: ", index)

## Désactive et nettoie tout
func disable_ghost() -> void:
	is_ghost_active = false
	selected_tower_scene = null
	
	if preview_sprite:
		preview_sprite.queue_free()
		preview_sprite = null


## Point d'entrée depuis l'UI
func _on_ui_add_tower_request(index: int) -> void:
	if index != -1:
		enable_ghost(index)
	else:
		disable_ghost()

func _on_mask_changed(new_mask: TileMapLayer) -> void:
	mask_layer = new_mask

func _register_initial_resources() -> void:
	if resources_container:
		for resource in resources_container.get_children():
			if is_instance_valid(resource):
				# On calcule la position dans la grille
				var res_tile = ground_layer.local_to_map(ground_layer.to_local(resource.global_position))
				# On l'ajoute au dictionnaire pour bloquer la construction
				occupied_cells[res_tile] = resource
