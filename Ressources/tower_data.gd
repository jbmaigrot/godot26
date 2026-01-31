extends Resource
class_name TowerData
@export var index: int = 0
@export var name: String = "Tour"
@export var cost_gold: int = 100
@export var cost_wood: int = 100
@export var cost_stone: int = 100
@export var scene: PackedScene        # Le prefab de la tour (pour Towers.gd)
@export var preview_scene: PackedScene # Le prefab du ghost (pour Towers.gd)
@export var icon: Texture2D           # Pour l'UI
