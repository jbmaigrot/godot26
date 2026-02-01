extends Node2D

var all_masks: Array[TileMapLayer] = []
var current_mask: TileMapLayer = null
var next_options: Array[TileMapLayer] = []

signal mask_changed(new_mask: TileMapLayer)

@export_range(0.0, 1.0) var preview_alpha: float = 0.3

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
	
	# On remplit les deux slots d'attente
	next_options.append(shuffle_bag.pop_front())
	next_options.append(shuffle_bag.pop_front())
	
	mask_changed.emit(current_mask)

func _process(_delta: float) -> void:
	# Debug : change le masque avec la touche Espace
	if Input.is_action_just_pressed("ui_accept"): # "ui_accept" est Espace par défaut
		select_next_mask(0)



# La fonction que tu appelles avec 0 ou 1
func select_next_mask(index: int) -> void:
	if index < 0 or index >= next_options.size():
		return

	# 1. On arrête proprement la preview de TOUTES les options
	# Cela remet la visibilité à false et l'alpha à 1.0
	for i in range(next_options.size()):
		hide_preview(i)

	# 2. On cache l'ancien masque actif
	if current_mask:
		current_mask.visible = false
		current_mask.self_modulate.a = 1.0
	
	# 3. On définit et on affiche le nouveau masque
	current_mask = next_options[index]
	current_mask.visible = true
	current_mask.self_modulate.a = 1.0 # Toujours plein d'opacité ici
	
	# 4. On génère les nouvelles options pour le tour suivant
	_update_options()
	
	mask_changed.emit(current_mask)

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
	
	print("Nouveau masque actif : ", current_mask.name)
	print("Options suivantes : 0:", next_options[0].name, " | 1:", next_options[1].name)
	
# Active la preview d'une option (0 ou 1)
func show_preview(index: int) -> void:
	if index < 0 or index >= next_options.size():
		return
	
	var target = next_options[index]
	# On s'assure qu'il est visible et on baisse l'opacité
	target.visible = true
	target.self_modulate.a = preview_alpha

# Désactive la preview d'une option
func hide_preview(index: int) -> void:
	if index < 0 or index >= next_options.size():
		return
		
	var target = next_options[index]
	# On le cache à nouveau et on reset son opacité pour la suite
	target.visible = false
	target.self_modulate.a = 1.0
	
