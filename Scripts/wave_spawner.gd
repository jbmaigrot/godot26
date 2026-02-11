extends Node2D

@export_group("Configuration")
@export var mob_spawner_scene: PackedScene
@onready var positions = [$Position1, $Position2, $Position3, $Position4]
@onready var wave_timer: Timer = $WaveTimer

@export_group("Difficulté Initiale")
@export var initial_wave_delay: float = 15.0
@export var initial_mob_count: int = 5
@export var initial_warning_time: float = 5.0
@export var initial_time_between_mobs: float = 1.0 
@export var min_time_between_mobs: float = 0.2
@export var boss_frequency: int = 5

@onready var player_base = %Player_base
@onready var mobs_container = %Mobs

var wave_number: int = 0

func _ready() -> void:
	wave_timer.timeout.connect(_on_wave_timeout)
	# On lance la première vague
	_on_wave_timeout()

func _on_wave_timeout() -> void:
	wave_number += 1
	
	# --- LOGIQUE DE DIFFICULTÉ ---
	# On réduit le délai entre les vagues (minimum 5s)
	var current_delay = max(5.0, initial_wave_delay - (wave_number * 0.5))
	# On augmente le nombre d'ennemis (ex: +1 tous les 2 vagues)
	var current_mob_count = initial_mob_count + floor(wave_number / 2.0)
	# On réduit légèrement le temps du camembert pour presser le joueur
	var current_warning = max(2.0, initial_warning_time - (wave_number * 0.2))
	# On réduit le délai entre chaque mob (réduit de 0.05s par vague, min 0.1s pour l'effet "mitraillette")
	var current_spawn_rate = max(min_time_between_mobs, initial_time_between_mobs - (wave_number * 0.05))
	
	# Appliquer le nouveau délai au timer pour la PROCHAINE vague
	wave_timer.wait_time = current_delay
	wave_timer.start()
	
	spawn_custom_pack(current_mob_count, current_warning, current_spawn_rate)

func spawn_custom_pack(count: int, warning: float, rate: float) -> void:
	if mob_spawner_scene:
		var pos_node = positions.pick_random()
		var spawner = mob_spawner_scene.instantiate()
		
		# INJECTION DES VARIABLES DANS LE MOB_SPAWNER
		spawner.target_node = player_base
		spawner.container_node = mobs_container
		spawner.amount_to_spawn = count
		spawner.warning_time = warning
		spawner.time_between_mobs = rate # <--- On injecte le nouveau taux
		if wave_number % boss_frequency == 0 :
			spawner.is_boss_wave = true
		spawner.global_position = pos_node.global_position
		add_child(spawner)
