extends CharacterBody2D

var inventory = [
	{
		"id": "wooden_spikes",
		"amount": 1
	},
	{
		"id": "fish",
		"amount": 3
	},
	{
		"id": "bug_net",
		"amount": 1
	}
]

@onready var world = get_parent()

var selected_item = 0
var busy = false
var can_move = true

var health = 100
var hunger = 100
var thirst = 100

var wooden_spikes_scene = preload("res://scenes/wooden_spikes.tscn")

func add_item(id: String, amount: int) -> bool:
	for n in inventory:
		if n.id == id:
			n.amount += amount
			
			if n.amount < 1:
				inventory.erase(n)
			
			_init_reload_held_item()
			return true
	
	var item = {
		"id": id,
		"amount": amount
	}
	
	if item.amount < 1:
		item.amount = 1
		
	inventory.push_back(item)
		
	_init_reload_held_item()
	return true
	
var swing = false
var swing_speed = 360

func _process(delta: float) -> void:
	velocity.y += 20
	velocity.x = 0
	
	hunger -= delta / 3
	thirst -= delta / 2.5
	if hunger > 100: hunger = 100
	if thirst > 100: thirst = 100
	
	rotation_degrees /= 1.1
	$Sprite.position.y /= 1.1
	
	var angle = (get_global_mouse_position() - global_position).normalized().angle()
	
	if typeof(swing) != typeof(false):
		$Item.rotation = angle
		swing += delta * swing_speed
		
		if (rad_to_deg(angle) > -90) and (rad_to_deg(angle) < 90):
			$Item.rotation_degrees += swing
		else:
			$Item.rotation_degrees -= swing
		
		if swing > 90:
			swing = false
			busy = false
			$Item/ItemSprite/SwingHitbox.position.y = 9e10
			
			if inventory[selected_item].id == "fish":
				hunger += 25
				
				add_item("fish", -1)
			elif inventory[selected_item].id == "worm_bait":
				world.next_fishing_loot_table = "fish_fishing"
				
				add_item("worm_bait", -1)
			elif inventory[selected_item].id == "wood_bait":
				world.next_fishing_loot_table = "gear_fishing"
				
				add_item("wood_bait", -1)
			elif inventory[selected_item].id == "metal_bait":
				world.next_fishing_loot_table = "metal_fishing"
				
				add_item("metal_bait", -1)
			elif inventory[selected_item].id == "wooden_spikes":
				var wooden_spikes = wooden_spikes_scene.instantiate()
			
				wooden_spikes.position = position
				
				if (rad_to_deg(angle) > -90) and (rad_to_deg(angle) < 90):
					wooden_spikes.position.x += 128
				else:
					wooden_spikes.position.x -= 128
					
				world.add_child(wooden_spikes)
				
				add_item("wooden_spikes", -1)
	else:
		$Item.rotation = angle
	
	if Input.is_action_just_pressed("use_current_item") and not busy:
		$Item/ItemSprite/SwingHitbox.position.y = 0
		swing = -90
		busy = true
	
	if (rad_to_deg(angle) > -90) and (rad_to_deg(angle) < 90):
		$Item/ItemSprite.scale.x = 0.75
		$Item/ItemSprite.scale.y = -0.75
	else:
		$Item/ItemSprite.scale.x = -0.75
		#$Item/ItemSprite.scale.y = 0.75
	
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
				$Item/ItemSprite.texture = load("res://textures/items/"+ inventory[i].id + ".png")
				
			i += 1
	
	if can_move: move_and_slide()
	
func _init_reload_held_item():
	if inventory.size() - 1 < selected_item:
		selected_item = inventory.size() - 1
	$Item/ItemSprite.texture = load("res://textures/items/"+ inventory[selected_item].id + ".png")
