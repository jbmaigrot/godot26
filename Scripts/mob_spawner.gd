extends Node2D

@export_group("Réglages du Pack")
@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var is_boss_wave :bool = false
@export var warning_time: float = 10.0  # Temps du camembert (ex: 10s)
@export var amount_to_spawn: int = 5    # Nombre total d'ennemis
@export var time_between_mobs: float = 1.0 # Délai entre chaque mob (ex: 1s)

@onready var mob_timer: Timer = $MobTimer
@export var progress_bar: TextureProgressBar 

var mobs_spawned_count: int = 0
var target_node: Node2D
var container_node: Node

func _ready() -> void:
	# 1. Préparation du camembert
	if progress_bar:
		progress_bar.value = 0
		progress_bar.max_value = 100
		progress_bar.show()
		
		# Animation du remplissage sur 10 secondes
		var tween = create_tween()
		tween.tween_property(progress_bar, "value", 100, warning_time)
	
	# 2. Timer pour le compte à rebours initial
	mob_timer.wait_time = warning_time
	mob_timer.one_shot = true
	mob_timer.timeout.connect(_on_countdown_finished)
	mob_timer.start()

func _on_countdown_finished() -> void:
	# Le premier délai est passé, on cache le camembert
	if progress_bar:
		progress_bar.hide()
	
	# 3. On change la logique du Timer pour le spawn en série
	mob_timer.timeout.disconnect(_on_countdown_finished)
	mob_timer.timeout.connect(_on_spawn_tick)
	
	mob_timer.wait_time = time_between_mobs
	mob_timer.one_shot = false
	mob_timer.start()
	
	# On fait apparaître le tout premier ennemi immédiatement
	_on_spawn_tick()

func _on_spawn_tick() -> void:
	if mobs_spawned_count < amount_to_spawn:
		# Pour les vagues de boss, on remplace le premier ennemi par un boss
		if is_boss_wave && mobs_spawned_count == 0:
			spawn_enemy(boss_scene)
		else:
			spawn_enemy(enemy_scene)
		mobs_spawned_count += 1
	
	# Une fois que tous les ennemis sont sortis, le spawner s'autodétruit
	if mobs_spawned_count >= amount_to_spawn:
		mob_timer.stop()
		queue_free()

func spawn_enemy(scene) -> void:
	if scene and container_node:
		var enemy = scene.instantiate()
		enemy.global_position = global_position
		enemy.target = target_node # On utilise la variable reçue
		container_node.add_child(enemy) # On utilise la variable reçue
