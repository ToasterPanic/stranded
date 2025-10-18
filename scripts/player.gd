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
		
	inventory.push_front(item)
		
	return true

func _process(delta: float) -> void:
	velocity.y += 20
	velocity.x = 0
	
	if Input.is_action_pressed("move_left"):
		velocity.x -= 200
	if Input.is_action_pressed("move_right"):
		velocity.x  += 200
		
	var i = 0
	while i < inventory.size():
		if Input.is_action_pressed("hotbar_item_" + str(i)):
			selected_item = i
			
		i += 1
	
	move_and_slide()
