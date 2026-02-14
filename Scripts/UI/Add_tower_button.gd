extends PanelContainer 

@export var tower_info: TowerData

# --- EXPORTS POUR LES NODES ---
@export_group("UI Nodes")
@export var name_label: Label
@export var desc_label: Label
@export var gold_label: Label
@export var wood_label: Label
@export var stone_label: Label
@export var main_icon: TextureRect

# Signal pour le jeu
signal add_tower_request(index: int)

func _ready() -> void:
	# 1. Configuration automatique des filtres de souris pour éviter les blocages
	mouse_filter = Control.MOUSE_FILTER_STOP
	_set_mouse_ignore_recursive(self)
	
	# 2. Connexion des signaux par code (100% automatisé)
	mouse_entered.connect(_on_mouse_hover)
	mouse_exited.connect(_on_mouse_out)
	gui_input.connect(_on_gui_input)
	
	update_ui()

# Fonction récursive pour que les enfants ne bloquent pas le clic du parent
func _set_mouse_ignore_recursive(node: Node):
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_set_mouse_ignore_recursive(child)

func update_ui() -> void:
	if not tower_info:
		push_warning("Aucune donnée TowerData sur ce bouton !")
		return

	if main_icon: main_icon.texture = tower_info.icon
	if name_label: name_label.text = tower_info.name
	if desc_label: desc_label.text = tower_info.description
	if gold_label: gold_label.text = str(tower_info.cost_gold)
	if wood_label: wood_label.text = str(tower_info.cost_wood)
	if stone_label: stone_label.text = str(tower_info.cost_stone)

# --- LOGIQUE D'INTERACTION ---

func _on_mouse_hover():
	# Effet visuel au survol (éclaircit tout le bouton, icônes incluses)
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_out():
	# Retour à la normale
	modulate = Color.WHITE

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Effet d'appui (assombrit)
			modulate = Color(0.7, 0.7, 0.7)
		else:
			# Relâchement du clic (équivalent du signal 'pressed')
			modulate = Color(1.2, 1.2, 1.2)
			_handle_press_logic()

func _handle_press_logic():
	if tower_info:
		add_tower_request.emit(tower_info.index)
		print("Tour sélectionnée : ", tower_info.name)
