extends TileMapLayer

@export var mask: TileMapLayer

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if mask == null: 
		return false
	
	if coords in mask.get_used_cells_by_id(0):
		return true
	return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in mask.get_used_cells_by_id(0):
		tile_data.set_navigation_polygon(0, null)

# Appelle cette fonction dès que tu dessines sur ton masque en jeu
func refresh():
	notify_runtime_tile_data_update()
