extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	print("An area overlapped me!")
	print(area.get_class())

func _on_body_entered(body):
	print("A body overlapped me!")
	print(body.get_class())
