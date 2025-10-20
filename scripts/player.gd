extends CharacterBody2D

var inventory = [
	{
		"id": "fish",
		"amount": 2
	},
	{
		"id": "planks",
		"amount": 2
	},
	{
		"id": "purified_water",
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
var umbrella_scene = preload("res://scenes/umbrella.tscn")

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
	
	hunger -= delta / 6
	thirst -= delta / 4.5
	if hunger > 100: hunger = 100
	if thirst > 100: thirst = 100
	
	rotation_degrees /= 1.1
	$Sprite.position.y /= 1.1
	
	if world.raining:
		var damage = true
		for n in world.get_children():
			if n.get_name() == "Umbrella":
				for o in n.get_node("UmbrellaArea").get_overlapping_bodies():
					print(o)
					if o.get_name() == "Player":
						damage = false
						break
		
		if damage:
			health -= delta / 3
	
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
				hunger += 50
				
				add_item("fish", -1)
			elif inventory[selected_item].id == "unpurified_water":
				thirst += 50
				health -= 15
				
				add_item("unpurified_water", -1)
			elif inventory[selected_item].id == "purified_water":
				thirst += 100
				
				add_item("purified_water", -1)
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
				if $PlacementZone/Area2D.get_overlapping_bodies().size() < 1:
					var wooden_spikes = wooden_spikes_scene.instantiate()
				
					wooden_spikes.position = position
					
					if (rad_to_deg(angle) > -90) and (rad_to_deg(angle) < 90):
						wooden_spikes.position.x += 128
					else:
						wooden_spikes.position.x -= 128
						
					world.add_child(wooden_spikes)
					
					add_item("wooden_spikes", -1)
			elif inventory[selected_item].id == "umbrella":
				if $PlacementZone/Area2D.get_overlapping_bodies().size() < 1:
					var umbrella = umbrella_scene.instantiate()
				
					umbrella.position = position
					
					if (rad_to_deg(angle) > -90) and (rad_to_deg(angle) < 90):
						umbrella.position.x += 128
					else:
						umbrella.position.x -= 128
						
					world.add_child(umbrella)
					
					add_item("umbrella", -1)
			elif inventory[selected_item].id == "smoke_starter":
				add_item("smoke_starter", -1)
				
				world.get_node("Campfire/BlackSmoke").emitting = true
				
				await get_tree().create_timer(20).timeout 
			
				world.get_node("Campfire/BlackSmoke").emitting = false
				
	else:
		$Item.rotation = angle
	
	if Input.is_action_just_pressed("use_current_item") and not busy:
		$Item/ItemSprite/SwingHitbox.position.y = 0
		swing = -90
		busy = true
	
	if (rad_to_deg(angle) > -90) and (rad_to_deg(angle) < 90):
		$Item/ItemSprite.scale.x = 0.75
		$Item/ItemSprite.scale.y = -0.75
		$PlacementZone.position.x = 64
	else:
		$Item/ItemSprite.scale.x = -0.75
		#$Item/ItemSprite.scale.y = 0.75
		$PlacementZone.position.x = -192
		
	if inventory[selected_item].id == "makeshift_laser_pointer":
		world.get_node("Laser").visible = true
		world.get_node("Laser").position = get_global_mouse_position()
		world.get_node("Laser/Line2D").points[1] = -(get_global_mouse_position() - position)
		
		for n in world.get_node("Laser/Area2D").get_overlapping_areas():
			if n.get_parent().get_name() == "Plane":
				n.get_parent().alertness += 5 * delta
	else:
		world.get_node("Laser").visible = false
		
	if inventory[selected_item].id == "wooden_spikes":
		$PlacementZone.visible = true
	elif inventory[selected_item].id == "umbrella":
		$PlacementZone.visible = true
	else:
		$PlacementZone.visible = false
		
	$PlacementZone.color = Color(0, 1, 0, 0.5)
		
	for n in $PlacementZone/Area2D.get_overlapping_bodies():
		$PlacementZone.color = Color(1, 0, 0, 0.5)
	
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

func _input(event: InputEvent) -> void:
	if busy:
		return
		
	if event.is_action_pressed("next_item"):
		selected_item += 1
		if selected_item > inventory.size() - 1:
			selected_item = 0
			
	if event.is_action_pressed("last_item"):
		selected_item -= 1
		if selected_item < 0:
			selected_item = inventory.size() - 1
