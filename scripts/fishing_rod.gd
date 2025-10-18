extends Sprite2D

var fishing = false

func _process(delta: float) -> void:
	$Label.visible = false
	for n in $Area.get_overlapping_bodies():
		if n.get_name() == "Player":
			$Label.visible = true
			if Input.is_action_just_pressed("interact"):
				if fishing:
					break
				
				fishing = true
				
				print("ASS")
