extends Node2D

var time = 0

var world_time = 99999999
var world_state = "night"
var day_counter = -1

var lastSpawn = 0
var spawns = 0
var next_fishing_loot_table = null

var raining = true

var plane_scene = preload("res://scenes/plane.tscn")

var item_button_scene = preload("res://scenes/item_button.tscn")
var crafting_recipe_button_scene = preload("res://scenes/crafting_recipe_button.tscn")
var enemy_entry_scene = preload("res://scenes/enemy_entry.tscn")
var hovered_item = -1

@onready var player = $Player
@onready var hud = $CanvasLayer/Control
@onready var hotbar = hud.get_node("Hotbar")
@onready var crafting_menu = hud.get_node("Menu/TabContainer/Crafting")
@onready var crafting_menu_list = crafting_menu.get_node("Scroll/Box")
@onready var crafting_menu_panel = crafting_menu.get_node("Panel")

func set_day(day: int):
	day_counter = day
	
func set_time(time: int):
	world_time = time

func _ready() -> void:
	var crafting_menu = hud.get_node("Menu/TabContainer/Crafting")
	var list = crafting_menu.get_node("Scroll/Box")
	var panel = crafting_menu.get_node("Panel")
	
	LimboConsole.register_command(player.add_item, "add_item", "Give item or take em away,.,.,")
	LimboConsole.register_command(set_day, "set_day", "Set the crrent day")
	LimboConsole.register_command(set_time, "set_time", "Set the crrent timenjiadng")
	
	list.get_node("CraftingRecipeButton").free()
	
	for key in Global.recipes:
		var value = Global.recipes[key]
		
		var crafting_recipe_button = crafting_recipe_button_scene.instantiate()
		crafting_recipe_button.name = key
		crafting_recipe_button.connect("pressed", _crafting_recipe_button_pressed.bind(crafting_recipe_button))
		
		list.add_child(crafting_recipe_button)
		
		var item = Global.items[key]
		
		crafting_recipe_button.icon = load("res://textures/items/"+ key +".png")
		crafting_recipe_button.text = item.name

func _process(delta: float) -> void:
	time += delta
	
	hud.get_node("Icons/Container/Health").value = player.health
	hud.get_node("Icons/Container/Hunger").value = player.hunger
	hud.get_node("Icons/Container/Thirst").value = player.thirst
	
	if world_state == "night":
		# Nights should be 60 seconds long
		world_time += delta * (450 / 60)
	else:
		world_time += delta
		
	hud.get_node("Time/HFlowContainer/DayCounter").text = "Day\n" + str(day_counter)
	
	hud.get_node("Hotbar").custom_minimum_size.y = hud.get_node("Hotbar/Container").size.y + 16
	if world_time > 450:
		world_time = 0
		
		if world_state == "day":
			world_state = "night"
			$Campfire/Light.visible = true
			$Campfire/Fire.emitting = true
			$Campfire/Smoke.emitting = true
			spawns = 0
			
			for n in Global.nights[day_counter].hazards:
				if n == "rain":
					raining = true
					$Rain/Particles.emitting = true
					$Rain/Particles2.emitting = true
					$Rain/Particles3.emitting = true
		else:
			world_state = "day"
			
			for n in $Enemies.get_children():
				n.queue_free()
				
			$Campfire/Light.visible = false
			$Campfire/Fire.emitting = false
			$Campfire/Smoke.emitting = false
			$Campfire/BlackSmoke.emitting = false
			
			raining = false
			$Rain/Particles.emitting = false
			$Rain/Particles2.emitting = false
			$Rain/Particles3.emitting = false
			
			day_counter += 1
			
			hud.get_node("Menu/TabContainer/Next Up/Container/Hazards").text = ""
			
			for n in Global.nights[day_counter].hazards:
				hud.get_node("Menu/TabContainer/Next Up/Container/Hazards").text += n + "\n"
				
			for n in hud.get_node("Menu/TabContainer/Next Up/Container/Enemies").get_children():
				n.queue_free()
			
			for n in Global.nights[day_counter].enemies:
				var enemy_entry = enemy_entry_scene.instantiate()
				
				enemy_entry.get_node("RichTextLabel").text = '''[font size=32]%s[/font]
%s''' % [Global.enemies[n].name, Global.enemies[n].description]
				
				hud.get_node("Menu/TabContainer/Next Up/Container/Enemies").add_child(enemy_entry)
			
	if world_state == "day":
		$NightSky.modulate.a /= 2
		hud.get_node("Time/HFlowContainer/Day").visible = true
		hud.get_node("Time/HFlowContainer/Day").value = 450 - world_time
		hud.get_node("Time/HFlowContainer/Night").visible = false
	elif world_state == "night":
		if $NightSky.modulate.a < 0.01:
			$NightSky.modulate.a = 0.01
		$NightSky.modulate.a /= 0.98
		hud.get_node("Time/HFlowContainer/Night").visible = true
		hud.get_node("Time/HFlowContainer/Night").value = 450 - world_time
		hud.get_node("Time/HFlowContainer/Day").visible = false
		
		lastSpawn += delta
		if lastSpawn > 2.5:
			lastSpawn = 0
			spawns += 1
			
			if spawns == 15:
				var plane = plane_scene.instantiate()
				
				plane.position = Vector2(1200, -300)
				add_child(plane)
				
			var night = Global.nights[day_counter]
			
			var spawn = night.enemies[randi_range(0, night.enemies.size() - 1)]
			var enemy = Global.enemies[spawn].scene.instantiate()
			
			enemy.player = player
			
			if randi_range(0, 1) == 0:
				enemy.global_position = $Spawn1.global_position
			else:
				enemy.global_position = $Spawn2.global_position
			
			$Enemies.add_child(enemy)
	
	$Water.position.x = sin(time * 2) * 200
	$Water2.position.x = sin((time + 7) * 2.1) * 200
	
	hud.get_node("HoverText").visible = hovered_item != -1
	
	var i = 0
	for n in player.inventory:
		var item_button = hotbar.get_node("Container").get_node("ItemButton" + str(i))
		
		if item_button and (item_button.get_meta("id") != n.id):
			item_button.free()
			item_button = null
		
		if not item_button:
			item_button = item_button_scene.instantiate()
			hotbar.get_node("Container").add_child(item_button)
			
			item_button.name = "ItemButton" + str(i)
			item_button.connect("pressed", _select_item_from_button.bind(item_button))
			item_button.connect("mouse_entered", _item_button_mouse_entered.bind(item_button))
			item_button.connect("mouse_exited", _item_button_mouse_exited.bind(item_button))
			item_button.set_meta("number", i)
			item_button.set_meta("id", n.id)
			
			item_button.get_node("Texture").texture = load("res://textures/items/" + n.id + ".png")
			item_button.get_node("Keybind").text = "[" + str(i + 1) + "] "
			
		if i == player.selected_item:
			item_button.modulate = Color(1, 1, 1, 1)
		else:
			item_button.modulate = Color(1, 1, 1, 0.666)
			
		item_button.get_node("Amount").text = " " + str(n.amount)
		
		if hovered_item == i:
			hud.get_node("HoverText").position = item_button.get_global_mouse_position()
			hud.get_node("HoverText").position.y -= hud.get_node("HoverText").size.y
			hud.get_node("HoverText/Text").text = """[font size=24]%s[/font]
%s""" % [Global.items[n.id].name, Global.items[n.id].description]
			hud.get_node("HoverText").size.y = 0
		
		i += 1
		
	for n in hotbar.get_node("Container").get_children():
		if n.get_meta("number") > player.inventory.size() - 1:
			n.free()
		elif player.inventory[n.get_meta("number")].id != n.get_meta("id"):
			n.free()

func _select_item_from_button(item_button: Node):
	if player.busy:
		return
	player.selected_item = item_button.get_meta("number")
	
func _item_button_mouse_entered(item_button: Node):
	hovered_item = item_button.get_meta("number")
	
func _item_button_mouse_exited(item_button: Node):
	hovered_item = -1
	
func _crafting_recipe_button_pressed(crafting_recipe_button: Node):
	var recipe = Global.recipes[crafting_recipe_button.name]
	var item = Global.items[crafting_recipe_button.name]
	
	crafting_menu_panel.get_node("Container/Item").texture = load(
		"res://textures/items/" + crafting_recipe_button.name + ".png"
	)
	crafting_menu_panel.get_node("Container/NameLabel").text = item.name
	crafting_menu_panel.get_node("Container/DescLabel").text = item.description
	
	var string = ""
	
	for n in recipe.ingredients:
		string = """%sx%s %s\n""" % [string, str(n.amount), Global.items[n.id].name]
		
	crafting_menu_panel.get_node("Container/IngredientsLabel").text = string
	
	crafting_menu_panel.set_meta("recipe", crafting_recipe_button.name)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		hud.get_node("Menu").visible = not hud.get_node("Menu").visible
		
		if hud.get_node("Menu").visible:
			player.busy = true
		else:
			player.busy = false


func _on_craft_button_pressed() -> void:
	if player.inventory.size() >= 10:
		return
	
	if not crafting_menu_panel.get_meta("recipe"):
		return
		
	var recipe = Global.recipes[crafting_menu_panel.get_meta("recipe")]
	
	for n in recipe.ingredients:
		var valid = false
		
		for v in player.inventory:
			if v.id == n.id:
				if v.amount >= n.amount:
					valid = true
		
		if not valid:
			return
			
	# All checks are done, now it's time to craft!!!!! :3:3:3:3:3
			
	for n in recipe.ingredients:
		for v in player.inventory:
			if v.id == n.id:
				v.amount -= n.amount
				
	for v in player.inventory:
		if v.amount < 1:
			player.inventory.erase(v)
				
	if not recipe.has("amount"):
		recipe.amount = 1

	player.add_item(crafting_menu_panel.get_meta("recipe"), recipe.amount)


func _on_main_menu_button_pressed() -> void:
	pass # Replace with function body.
