extends Control

@export_group("UI Elements")
@export var mask_one_button: Button
@export var mask_two_button: Button
@export var progress_bar: ProgressBar

@export_group("Settings")
@onready var timer: Timer = $Timer
@onready var manager = $"../../Masks_manager"
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
	
	# Connexion automatique du timeout du Timer
	timer.timeout.connect(_on_timer_timeout)

# Dans ton _process, remplace la logique actuelle par celle-ci :
func _process(_delta: float) -> void:
	if timer.time_left > 0:
		# 1. Calcul du ratio global (0.0 à 1.0)
		var ratio = (timer.wait_time - timer.time_left) / timer.wait_time
		progress_bar.value = ratio * 100
		
		# 2. Logique de couleur "Tension"
		# On définit à partir de quel moment (en %) on commence à devenir rouge
		var start_red_at = 0.7  # 70% du temps écoulé (donc 30% restants)
		
		if ratio > start_red_at:
			# On calcule un nouveau ratio spécifique pour la fin (0.0 à 1.0)
			# clamp permet de rester entre 0 et 1 pour éviter les erreurs de calcul
			var red_ratio = clamp((ratio - start_red_at) / (1.0 - start_red_at), 0.0, 1.0)
			
			# Transition du Blanc vers le Rouge
			progress_bar.modulate = Color.WHITE.lerp(Color.RED, red_ratio)
		else:
			# Avant le seuil, la barre reste d'une couleur normale
			progress_bar.modulate = Color.WHITE
	else:
		progress_bar.modulate = Color.WHITE
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

# --- Logique du Cycle ---
func _on_timer_timeout() -> void:
	execute_cycle_action()
	print("Action effectuée ! Reset du cycle.")

func execute_cycle_action():
	manager.select_next_mask(pending_selection)
	
	# button_pressed renvoie true si le bouton est en mode "Toggle" et activé
	if mask_one_button.button_pressed:
		print("Application du Mask 1")
	elif mask_two_button.button_pressed:
		print("Application du Mask 2")
	else:
		print("Aucun masque sélectionné")
