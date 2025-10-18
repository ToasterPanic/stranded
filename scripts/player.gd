extends CharacterBody2D

var inventory = [
	{
		"id": "planks",
		"amount": 1
	},
	{
		"id": "fish",
		"amount": 3
	}
]

var selected_item = 0
var busy = false
var can_move = true

var health = 100
var hunger = 100
var thirst = 100


func add_item(id: String, amount: int) -> bool:
	for n in inventory:
		if n.id == id:
			n.amount += amount
			
			return true
	
	var item = {
		"id": id,
		"amount": amount
	}
	
	if item.amount < 1:
		item.amount = 1
		
	inventory.push_back(item)
		
	return true

func _process(delta: float) -> void:
	velocity.y += 20
	velocity.x = 0
	
	rotation_degrees /= 1.1
	$Sprite.position.y /= 1.1
	
	if Input.is_action_pressed("move_left"):
		velocity.x -= 200
		$Sprite.scale.x = 1
	if Input.is_action_pressed("move_right"):
		velocity.x  += 200
		$Sprite.scale.x = -1
		
	if abs(velocity.x) > 0:
		rotation_degrees = sin(get_parent().time * 12) * 5
		$Sprite.position.y = (sin(get_parent().time * 24) * 5) - 5
		
	if not busy:
		var i = 0
		while i < inventory.size():
			if Input.is_action_pressed("hotbar_item_" + str(i)):
				selected_item = i
				
			i += 1
	
	if can_move: move_and_slide()
