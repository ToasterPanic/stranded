extends RigidBody2D

var durability = 10

func _process(delta: float) -> void:
	if durability < 1:
		queue_free()
