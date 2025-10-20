extends RigidBody2D

var durability = 20

func _process(delta: float) -> void:
	if durability < 1:
		queue_free()
		
	if durability < 20:
		$Durability.visible = true
		$Durability.value = durability
