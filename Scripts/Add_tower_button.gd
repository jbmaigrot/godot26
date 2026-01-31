extends TextureButton

# Correction de l'export : on définit le type int et une valeur par défaut

@export var tower_info: TowerData

# Signal que le contrôleur UI va écouter
signal add_tower_request(index: int)

func _ready() -> void:
	# Connexion propre du clic
	self.pressed.connect(_on_self_pressed)
	
	# MISE À JOUR AUTOMATIQUE DE LA TEXTURE
	if tower_info:
		# On définit la texture normale du bouton
		texture_normal = tower_info.icon 
		# Optionnel : si tu as des textures de survol/clic, tu peux les gérer ici
	else:
		push_warning("Bouton de tour sans TowerData assigné !")

func _on_self_pressed() -> void:
	# On émet simplement l'ID de ce bouton
	var index = tower_info.index
	add_tower_request.emit(index)
	print("Bouton cliqué, envoi de la tour ID : ", index)
