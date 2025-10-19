extends Node2D

var time = 0

var world_time = 0
var world_state = "day"
var day_counter = 0

var lastSpawn = 0
var next_fishing_loot_table = null

var item_button_scene = preload("res://scenes/item_button.tscn")
var crafting_recipe_button_scene = preload("res://scenes/crafting_recipe_button.tscn")
var hovered_item = -1

@onready var player = $Player
@onready var hud = $CanvasLayer/Control
@onready var hotbar = hud.get_node("Hotbar")
@onready var crafting_menu = hud.get_node("Menu/TabContainer/Crafting")
@onready var crafting_menu_list = crafting_menu.get_node("Scroll/Box")
@onready var crafting_menu_panel = crafting_menu.get_node("Panel")

func _ready() -> void:
	var crafting_menu = hud.get_node("Menu/TabContainer/Crafting")
	var list = crafting_menu.get_node("Scroll/Box")
	var panel = crafting_menu.get_node("Panel")
	
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
		world_time += delta * (450 / 30)
	else:
		world_time += delta
		
	hud.get_node("Time/HFlowContainer/DayCounter").text = "Day\n" + str(day_counter)
	
	if world_time > 450:
		world_time = 0
		
		if world_state == "day":
			world_state = "night"
			$Campfire/Light.visible = true
			$Campfire/Fire.emitting = true
		else:
			world_state = "day"
			$Campfire/Light.visible = false
			$Campfire/Fire.emitting = false
			
			day_counter += 1
			
			hud.get_node("Menu/TabContainer/Next Up/Hazards").text = ""
			
			for n in Global.nights[day_counter].hazards:
				hud.get_node("Menu/TabContainer/Next Up/Hazards").text += n + "\n"
				
			hud.get_node("Menu/TabContainer/Next Up/Enemies").text = ""
			
			for n in Global.nights[day_counter].enemies:
				hud.get_node("Menu/TabContainer/Next Up/Enemies").text += n + "\n"
			
	if world_state == "day":
		$NightSky.modulate.a /= 1.1
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
			var night = Global.nights[day_counter]
			
			var spawn = night.enemies[randi_range(0, night.enemies.size() - 1)]
			var enemy = Global.enemies[spawn].instantiate()
			
			enemy.player = player
			
			if randi_range(0, 1) == 0:
				enemy.position = $Spawn1.position
			else:
				enemy.position = $Spawn2.position
			
			add_child(enemy)
	
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
