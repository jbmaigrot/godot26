extends CharacterBody2D
class_name Enemy

@export var speed = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#(temp/debug) control the enemy
	var moveDirection = Vector2()
	if (Input.is_key_pressed(KEY_LEFT)):
		moveDirection.x -= 1
	if (Input.is_key_pressed(KEY_RIGHT)):
		moveDirection.x += 1
	if (Input.is_key_pressed(KEY_UP)):
		moveDirection.y -= 1
	if (Input.is_key_pressed(KEY_DOWN)):
		moveDirection.y += 1
	
	velocity = moveDirection * speed
	move_and_slide()
