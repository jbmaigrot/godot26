extends Button

@export var tower_info: TowerData

# --- EXPORTS POUR LES NODES (À glisser dans l'inspecteur) ---
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
	self.pressed.connect(_on_self_pressed)
	update_ui()

func update_ui() -> void:
	if not tower_info:
		push_warning("Aucune donnée TowerData sur ce bouton !")
		return

	if main_icon:
		main_icon.texture = tower_info.icon

	# Mise à jour des textes (on vérifie chaque node un par un)
	if name_label:
		name_label.text = tower_info.name
	
	if desc_label:
		desc_label.text = tower_info.description
		
	# Mise à jour des coûts
	if gold_label:
		gold_label.text = str(tower_info.cost_gold)
	
	if wood_label:
		wood_label.text = str(tower_info.cost_wood)
		
	if stone_label:
		stone_label.text = str(tower_info.cost_stone)

func _on_self_pressed() -> void:
	# On utilise une variable d'index si elle existe dans ton TowerData
	# Sinon on peut envoyer l'objet tower_info directement
	add_tower_request.emit(tower_info.index) 
	print("Tour sélectionnée : ", tower_info.name)
