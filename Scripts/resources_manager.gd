extends Node2D

# Signal pour envoyer les données au Main ou à l'UI
signal production_changed(wood_per_sec: float, stone_per_sec: float)

var total_wood_ps: float = 0.0
var total_stone_ps: float = 0.0

@onready var mask_manager = $"../Masks_manager"



func _ready() -> void:
	# On ne calcule RIEN ici, on attend que le Main ou le MaskManager soit prêt
	if mask_manager:
		mask_manager.mask_changed.connect(_on_mask_changed)
	
func update_totals() -> void:
	var current_wood = 0.0
	var current_stone = 0.0
	
	for child in get_children():
			# IMPORTANT : Si le jeu vient de se lancer, _filter_all_entities() 
			# doit avoir tourné pour que is_processing soit correct.
			if is_instance_valid(child) and child.is_processing(): 
				if "wood_production_value" in child:
					current_wood += child.wood_production_value
				if "stone_production_value" in child:
					current_stone += child.stone_production_value
	
	total_wood_ps = current_wood
	total_stone_ps = current_stone
	production_changed.emit(total_wood_ps, total_stone_ps)

# Cette fonction est appelée automatiquement quand le signal est émis
func _on_mask_changed(_new_mask) -> void:
	# On attend la fin de la frame pour être sûr que les entités 
	# ont bien reçu leur set_process(active) via le filtre
	update_totals.call_deferred()
