extends Area2D
class_name Tower

@export var projectile_scene : PackedScene

@export var shoot_cooldown = 2
var current_cooldown = 0

var target :Enemy = null
var enemies_in_range = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (current_cooldown > 0):
		current_cooldown = current_cooldown - delta
	else:
		if !(target in enemies_in_range):
			target = null
		if (!target && enemies_in_range.size()!=0):
			target = enemies_in_range[0]
		if (target):
			shoot()
			current_cooldown = shoot_cooldown

func _on_body_entered(body):
	if body is Enemy:
		enemies_in_range.append(body)
		
func _on_body_exited(body):
	if body is Enemy:
		enemies_in_range.erase(body)

func shoot():
		var projectile :Projectile = projectile_scene.instantiate()
		add_child(projectile)
		
		# projectile spawns on tower and targets incoming enemy (body)
		projectile.position = position
		projectile.target = target
	
