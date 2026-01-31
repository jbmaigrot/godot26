extends Area2D
class_name Projectile

@export var speed = 100
@export var damage = 10

var target : Enemy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		global_position = global_position.move_toward(target.global_position, speed*delta)
		look_at(target.global_position)
		if global_position.distance_to(target.global_position) < 5:
				_on_impact()
	else:
		# If target dies before projectile hits, remove the projectile
		queue_free()
		
		
func _on_impact():
	# 3. Call the function on the target
	if target.has_method("take_damage"):
		target.take_damage(damage)
	
	# 4. Destroy the projectile
	queue_free()
