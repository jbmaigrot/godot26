extends Area2D
class_name Projectile

@export var speed = 100

var target : Enemy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		global_position = global_position.move_toward(target.global_position, speed*delta)
		look_at(target.global_position)
	pass
