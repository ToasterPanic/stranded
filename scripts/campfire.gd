extends Sprite2D

var fishing = false

func _process(delta: float) -> void:
	$Label.visible = false
	for n in $Area.get_overlapping_bodies():
		if n.get_name() == "Player":
			if get_parent().world_state == "day":
				$Label.visible = true
				if Input.is_action_just_pressed("interact"):
					get_parent().world_time = 9999
