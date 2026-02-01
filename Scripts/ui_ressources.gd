extends Control

@export var gold_label: Label
@export var wood_label: Label
@export var stone_label: Label
@export var health_label: Label  # Nouveau label pour les unités tuées
@export var kills_label: Label  # Nouveau label pour les unités tuées
@export var timer_label: Label # Nouveau label pour le temps

# Met à jour l'or
func update_gold(amount: int) -> void:
	gold_label.text = str(amount)

# Met à jour le bois
func update_wood(amount: int, production: int) -> void:
	wood_label.text = str(amount) + " (+" + str(production) + "/s)"

# Met à jour la pierre
func update_stone(amount: int, production: int) -> void:
	stone_label.text = str(amount) + " (+" + str(production) + "/s)"

# --- NOUVELLES FONCTIONS ---

# Met à jour le nombre d'unités tuées
func update_kills(count: int) -> void:
	kills_label.text = "Kills: " + str(count)

# Met à jour l'affichage du temps (format MM:SS)
func update_timer(seconds: int) -> void:
	var mins = seconds / 60
	var secs = seconds % 60
	# format("%02d") permet d'avoir toujours deux chiffres (ex: 05 au lieu de 5)
	timer_label.text = str("%02d:%02d" % [mins, secs])

func update_health(current: int, max_hp: int) -> void:
	health_label.text = "HP: " + str(current) + " / " + str(max_hp)
