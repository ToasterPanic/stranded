extends Sprite2D

var alertness = 0

func _process(delta: float) -> void:
	if alertness > 0:
		$Alertness.visible = true
	$Alertness.value = alertness
	position.x -= 128 * delta
	
	if get_parent().has_node("Campfire"):
		if get_parent().get_node("Campfire/BlackSmoke").emitting:
			alertness += 10 * delta
			
	if alertness >= 100:
		get_parent().get_node("CanvasLayer/Control/YouWin").visible = true
		get_tree().paused = true
	
	if position.x < -4000:
		queue_free()
