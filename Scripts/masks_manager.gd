extends Node2D

var all_masks: Array[TileMapLayer] = []
var current_mask: TileMapLayer = null
var next_options: Array[TileMapLayer] = []

signal mask_changed(new_mask: TileMapLayer)

@export_range(0.0, 1.0) var preview_alpha: float = 0.3
@export var transition_duration: float = 0.5


@onready var towers_container = $"../Towers"
@onready var mobs_container = $"../Mobs"
@onready var resources_container = $"../Resources"

var is_transitioning: bool = false

func _ready() -> void:
	# 1. Récupération dynamique des enfants
	for child in get_children():
		if child is TileMapLayer:
			all_masks.append(child)
			child.visible = false
	
	if all_masks.size() < 3:
		push_error("Pas assez de TileMapLayers enfants !")
		return

	# Initialisation : on pioche 3 masques au hasard pour commencer
	var shuffle_bag = all_masks.duplicate()
	shuffle_bag.shuffle()
	
	current_mask = shuffle_bag.pop_front()
	current_mask.visible = true
	
	_filter_all_entities()
	mask_changed.emit(current_mask)
	
	# On remplit les deux slots d'attente
	next_options.append(shuffle_bag.pop_front())
	next_options.append(shuffle_bag.pop_front())
	

func select_next_mask(index: int) -> void:
	if is_transitioning or index < 0 or index >= next_options.size():
		return

	is_transitioning = true # On verrouillen

	var old_mask = current_mask
	var new_mask = next_options[index]
	
	# On cache les previews proprement avant de démarrer
	hide_preview(0)
	hide_preview(1)
	# 1. Préparation du nouveau masque
	new_mask.visible = true
	new_mask.self_modulate.a = 0.0
	
	# 2. Animation fluide avec Tween
	var tween = create_tween().set_parallel(true)
	
	# On fait apparaître le nouveau et disparaître l'ancien
	tween.tween_property(new_mask, "self_modulate:a", 1.0, transition_duration)
	if old_mask:
		tween.tween_property(old_mask, "self_modulate:a", 0.0, transition_duration)

	# 3. Actions de fin de transition
	# .chain() permet d'attendre la fin des animations précédentes
	tween.chain().tween_callback(func():
		if old_mask:
			old_mask.visible = false
			old_mask.self_modulate.a = 1.0
		
		current_mask = new_mask
		
		_update_options()
		_filter_all_entities() # Appliqué quand le sol est totalement là
		is_transitioning = false # On déverrouille à la fin !
		mask_changed.emit(current_mask)
	)

# On modifie un peu _apply_status pour que ce soit raccord visuellement
func _apply_status(entity: Node2D, active: bool) -> void:
	# On synchronise la visibilité de l'unité avec son état d'activation
	entity.visible = active 
	entity.set_process(active)
	entity.set_physics_process(active)
	
	for child in entity.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", !active)

func _update_options() -> void:
	next_options.clear()
	
	# On crée une liste excluant le masque actuel pour ne pas retomber dessus direct
	var available = all_masks.duplicate()
	available.erase(current_mask)
	available.shuffle()
	
	for i in range(2):
		var opt = available[i]
		opt.visible = false       # Sécurité
		opt.self_modulate.a = 1.0 # Sécurité
		next_options.append(opt)
	
	# On reprend les deux premières
	next_options.append(available[0])
	next_options.append(available[1])
	
	
# Active la preview d'une option (0 ou 1)
func show_preview(index: int) -> void:
	if is_transitioning or index < 0 or index >= next_options.size():
		return
	
	var target = next_options[index]
	# On s'assure qu'il est visible et on baisse l'opacité
	target.visible = true
	target.self_modulate.a = preview_alpha

# Désactive la preview d'une option
func hide_preview(index: int) -> void:
	if is_transitioning or index < 0 or index >= next_options.size():
		return
		
	var target = next_options[index]
	# On le cache à nouveau et on reset son opacité pour la suite
	target.visible = false
	target.self_modulate.a = 1.0
	

func _filter_all_entities() -> void:
	# 1. On vérifie d'abord que les nœuds parents eux-mêmes existent (pas null)
	if towers_container == null or mobs_container == null or resources_container == null:
		push_warning("Un ou plusieurs conteneurs sont manquants (null).")
		return

	# 2. On traite chaque groupe seulement s'ils ont des enfants
	if towers_container.get_child_count() > 0:
		_process_group(towers_container.get_children(), "HIDE")
	
	if mobs_container.get_child_count() > 0:
		_process_group(mobs_container.get_children(), "DELETE")
		
	if resources_container.get_child_count() > 0:
		_process_group(resources_container.get_children(), "HIDE")
	
func _process_group(entities: Array, mode: String) -> void:
	for entity in entities:
		# Sécurité supplémentaire : on vérifie que l'entité est bien un Node2D
		# et qu'elle n'est pas déjà en train d'être supprimée
		if is_instance_valid(entity) and entity is Node2D:
			
			var map_pos = current_mask.local_to_map(current_mask.to_local(entity.global_position))
			var has_ground = current_mask.get_cell_tile_data(map_pos) != null
			
			if !has_ground:
				_apply_status(entity, true)
			else:
				if mode == "DELETE":
					print("unit deleted by fog")
					entity.queue_free()
				else:
					print("unit desactivated by fog")
					_apply_status(entity, false)
