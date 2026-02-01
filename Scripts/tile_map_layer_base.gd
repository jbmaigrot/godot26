extends TileMapLayer

## Le layer qui sert d'obstacle (doit être parfaitement aligné au sol)
#@export var mask: TileMapLayer
var active_mask: TileMapLayer = null

func _ready() -> void:
	await get_tree().process_frame
	
	# 1. On trouve le gestionnaire
	var manager = $"../Masks_manager"
	if manager:
		# On s'abonne au changement de masque (si tu as créé le signal)
		# Ou on récupère simplement le masque actuel au début
		active_mask = manager.current_mask
		
		# Optionnel : Connecter un signal pour mettre à jour automatiquement
		manager.mask_changed.connect(_on_mask_changed)

	update_navigation_map()

# Cette fonction force la TileMap à re-parcourir toutes ses tuiles
func update_navigation_map() -> void:
	notify_runtime_tile_data_update()
	# Le serveur de navigation a besoin de savoir que les polygones ont changé
	NavigationServer2D.map_changed.emit(get_world_2d().get_navigation_map())


func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if active_mask == null:
		return false
	
	# On vérifie si le masque ACTUEL a une tuile ici
	return active_mask.get_cell_source_id(coords) != -1

func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:
	# On supprime la navigation là où le masque est présent
	tile_data.set_navigation_polygon(0, null)

# Appelé par le Manager quand le joueur choisit un nouveau masque
func _on_mask_changed(new_mask: TileMapLayer) -> void:
	active_mask = new_mask
	# On désactive temporairement la navigation pour forcer un nettoyage
	set_navigation_enabled(false)
	
	# On attend la fin de la frame pour être sûr que Godot a digéré l'arrêt
	await get_tree().process_frame 
	
	set_navigation_enabled(true)
	update_navigation_map()
	update_navigation_map()
