extends Node2D

# Export variables allow you to tweak these in the Godot Inspector
@export var enemy_scene: PackedScene  # Drag your Enemy.tscn here
@export var spawn_delay: float = 2.0  # Seconds between spawns

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.wait_time = spawn_delay
	# Connect the timer's timeout signal to our spawn function
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	if enemy_scene:
		# 1. Create an instance of the mob
		var enemy = enemy_scene.instantiate()
	
		# 2. Set its position (usually the spawner's position)
		enemy.position = global_position
		enemy.target = $"../Player_base"
		
		# 3. Add it to the scene tree
		# Note: Adding it to 'get_parent()' prevents the mob from moving 
		# WITH the spawner if the spawner moves.
		get_parent().add_child(enemy)
	else:
		print("Warning: No enemy_scene assigned to the MobSpawner!")
