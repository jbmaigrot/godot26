extends Node2D

@export var mob_spawner_scene: PackedScene
@export var wave_delay: float = 15.0

@onready var wave_timer: Timer = $WaveTimer
@onready var positions = [$Position1, $Position2, $Position3, $Position4]

# On récupère les références ici une seule fois
@onready var player_base = %Player_base
@onready var mobs_container = %Mobs

func _ready() -> void:
	wave_timer.wait_time = wave_delay
	wave_timer.timeout.connect(_on_wave_timeout)
	wave_timer.start()
	_on_wave_timeout()

func _on_wave_timeout() -> void:
	if mob_spawner_scene:
		var pos_node = positions.pick_random()
		var spawner = mob_spawner_scene.instantiate()
		
		# On injecte les variables AVANT d'ajouter l'enfant à l'arbre
		spawner.target_node = player_base
		spawner.container_node = mobs_container
		
		spawner.global_position = pos_node.global_position
		add_child(spawner)
