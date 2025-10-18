extends CharacterBody2D

var player = null

func _process(delta: float) -> void:
	velocity.y += 20
	velocity.x = 0
	
	rotation_degrees /= 1.1
	$Sprite.position.y /= 1.1
	
	if player:
		if position.x < player.position.x:
			velocity.x += 100
			$Sprite.scale.x = -1
		else:
			velocity.x -= 100
			$Sprite.scale.x = 1
		
	if abs(velocity.x) > 0:
		rotation_degrees = sin(get_parent().time * 6) * 5
		$Sprite.position.y = (sin(get_parent().time * 12) * 5) - 5
	
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.get_name() == "Player":
		body.health -= 5
		
		position = Vector2(9e10, 9e10)
		queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	print(area)
	if area.get_name() == "SwingHitbox":
		if player.inventory[player.selected_item].id == "bug_net":
			position = Vector2(9e10, 9e10)
			queue_free()
