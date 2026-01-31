extends Node2D



@export_group("Configurations")

@export var tower_scene: PackedScene 

@export_group("Références")
@export var ground_layer: TileMapLayer 
@export var mask_layer: TileMapLayer 

@export var preview_sprite: Sprite2D

@export_group("Apparence")
@export var color_valid: Color = Color(0, 1, 0, 0.5) 
@export var color_invalid: Color = Color(1, 0, 0, 0.5)


var occupied_cells: Dictionary = {}
var buildable_data_name: String = "buildable"
var is_ghost_active: bool = false
var off_screen_pos: Vector2 = Vector2(-10000, -10000) # Position de sécurité

var main:Main = null

func _ready() -> void:
	main = get_tree().current_scene as Main
	disable_ghost()

func _process(_delta):
	
	if not ground_layer or not preview_sprite:
		return

	if is_ghost_active == false:
		return


	var mouse_pos = get_global_mouse_position()
	var local_pos = ground_layer.to_local(mouse_pos)
	var tile_pos = ground_layer.local_to_map(local_pos)
	
	preview_sprite.global_position = ground_layer.map_to_local(tile_pos)
	
	if can_build_at(tile_pos):
		preview_sprite.modulate = color_valid
		# Utilisation de Input.is_mouse_button_pressed pour le clic gauche
		if Input.is_action_just_pressed("left_click"):
			# On vérifie encore si on peut construire pour éviter les doublons
			place_tower(tile_pos)
	else:
		preview_sprite.modulate = color_invalid

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
	# Optionnel : une petite sécurité pour ne pas spammer dans le _process
	if occupied_cells.has(tile_pos): return
	
	print("tour construite")
	var new_tower = tower_scene.instantiate()
	add_child(new_tower)
	new_tower.global_position = ground_layer.map_to_local(tile_pos)
	occupied_cells[tile_pos] = new_tower
	
	print("tower built")

## Désactive le mode fantôme et dégage l'objet de la vue
func disable_ghost() -> void:
	is_ghost_active = false
	preview_sprite.global_position = off_screen_pos

## Réactive le mode fantôme
func enable_ghost() -> void:
	is_ghost_active = true


func _on_ui_add_tower_request(is_active: bool) -> void:
	if is_active:
		enable_ghost()
	else:
		disable_ghost()
