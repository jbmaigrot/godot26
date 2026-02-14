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
@export var progress_bar_boss: TextureProgressBar  
var active_bar: TextureProgressBar

@export var spawn_particles: CPUParticles2D

var mobs_spawned_count: int = 0
var target_node: Node2D
var container_node: Node

func _ready() -> void:
	# 1. Sélection de la barre à utiliser
	if is_boss_wave and progress_bar_boss:
		active_bar = progress_bar_boss
		if progress_bar: progress_bar.hide() # On cache l'autre par sécurité
	else:
		active_bar = progress_bar
		if progress_bar_boss: progress_bar_boss.hide()
	
	
	# 1. Préparation du camembert
	if active_bar:
		active_bar.value = 0
		active_bar.max_value = 100
		active_bar.show()
		if is_boss_wave:
			active_bar.tint_under = Color.RED
		
		# Animation du remplissage sur 10 secondes
		var tween = create_tween()
		tween.tween_property(active_bar, "value", 100, warning_time)
	
	# 2. Timer pour le compte à rebours initial
	mob_timer.wait_time = warning_time
	mob_timer.one_shot = true
	mob_timer.timeout.connect(_on_countdown_finished)
	mob_timer.start()

func _on_countdown_finished() -> void:
	# Le premier délai est passé, on cache le camembert
	if progress_bar:
		pass
		#progress_bar.hide()
	
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
		
		if progress_bar:
			# Création d'un tween pour une disparition fluide
			var fade_tween = create_tween()
			# On fait passer l'opacité (modulate.a) à 0 en 0.5 seconde
			fade_tween.tween_property(progress_bar, "modulate:a", 0.0, 0.5)
			
			# On attend que l'animation soit finie avant de détruire le spawner
			fade_tween.finished.connect(func(): queue_free())
		else:
			# Si pas de barre, on détruit immédiatement
			queue_free()

func spawn_enemy(scene) -> void:
	if scene and container_node:
		var enemy = scene.instantiate()
		enemy.global_position = global_position
		enemy.target = target_node # On utilise la variable reçue
		container_node.add_child(enemy) # On utilise la variable reçue
		if spawn_particles:
			# Pas besoin de modifier la position si le node est déjà enfant du spawner
			spawn_particles.restart() 
			spawn_particles.emitting = true
