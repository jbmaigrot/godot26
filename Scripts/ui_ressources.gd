extends Control

@export var gold_label: Label
@export var wood_label: Label
@export var stone_label: Label

# Met à jour l'or (Valeur simple)
func update_gold(amount: int) -> void:
	gold_label.text = str(amount)

# Met à jour le bois (Valeur + Production)
func update_wood(amount: int, production: int) -> void:
	wood_label.text = str(amount) + " (+" + str(production) + "/s)"

# Met à jour la pierre (Valeur + Production)
func update_stone(amount: int, production: int) -> void:
	stone_label.text = str(amount) + " (+" + str(production) + "/s)"
