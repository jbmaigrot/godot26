extends Control

@export_group("UI Elements")
@export var mask_one_button: Button
@export var mask_two_button: Button
@export var progress_bar: ProgressBar

@export_group("Settings")
#@onready var timer: Timer = $Timer
@onready var manager = $"../../Masks_manager"
@export var anim_player: AnimationPlayer
var pending_selection: int = 0

func _ready() -> void:
	# Connexion des signaux pour Mask One
	mask_one_button.mouse_entered.connect(_on_mask_one_hover)
	mask_one_button.mouse_exited.connect(_on_mask_one_exit)
	mask_one_button.toggled.connect(_on_mask_one_toggled) # On utilise toggled
	
	# Connexion des signaux pour Mask Two
	mask_two_button.mouse_entered.connect(_on_mask_two_hover)
	mask_two_button.mouse_exited.connect(_on_mask_two_exit)
	mask_two_button.toggled.connect(_on_mask_two_toggled) # On utilise toggled
	
	anim_player.animation_finished.connect(_on_animation_player_finished)
	
	# Lancement de l'animation de cycle
	anim_player.play("10 sec charging")

# Nouvelle fonction pour intercepter la fin de n'importe quelle animation
func _on_animation_player_finished(anim_name: String):
	if anim_name == "10 sec charging":
		_on_cycle_finished()
		# Si ton animation n'est pas en "Loop" dans l'éditeur, 
		# tu dois la relancer manuellement ici :
		anim_player.play("10 sec charging")

# --- Logique Mask One ---
func _on_mask_one_hover():
	manager.show_preview(0)

func _on_mask_one_exit():
	manager.hide_preview(0)

func _on_mask_one_selected():
	pending_selection = 0

func _on_mask_one_toggled(is_pressed: bool):
	if is_pressed:
		pending_selection = 0

func _on_mask_two_toggled(is_pressed: bool):
	if is_pressed:
		pending_selection = 1
		
# --- Logique Mask Two ---
func _on_mask_two_hover():
	manager.show_preview(1)

func _on_mask_two_exit():
	manager.hide_preview(1)

func _on_mask_two_selected():
	pending_selection = 1

func _on_cycle_finished():
	execute_cycle_action()
	# L'animation redémarre (ou est en boucle dans l'AnimationPlayer)
	print("Cycle terminé via AnimationPlayer")
	
	
func execute_cycle_action():
	manager.select_next_mask(pending_selection)
	
	if mask_one_button.button_pressed:
		print("Application du Mask 1")
	elif mask_two_button.button_pressed:
		print("Application du Mask 2")
