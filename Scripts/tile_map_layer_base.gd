extends TileMapLayer

## Le layer qui sert d'obstacle (doit être parfaitement aligné au sol)
@export var mask: TileMapLayer

func _ready() -> void:
	# On attend une frame pour que les transforms soient bien appliqués
	await get_tree().process_frame
	
	if mask == null:
		push_warning("Le layer 'mask' n'est pas assigné dans l'inspecteur !")
	
	# Force le rafraîchissement des données au démarrage
	notify_runtime_tile_data_update()
	
	# On demande au serveur de navigation de mettre à jour sa carte
	NavigationServer2D.map_changed.emit(get_world_2d().get_navigation_map())

## Étape 1 : On définit quelles tuiles doivent être mises à jour
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if mask == null:
		return false
	
	# Si le masque possède une tuile à ces coordonnées, on renvoie 'true'
	return mask.get_cell_source_id(coords) != -1

## Étape 2 : On modifie les données de la tuile (suppression navigation)
func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:
	# On vide le polygone de navigation sur le layer 0
	tile_data.set_navigation_polygon(0, null)
