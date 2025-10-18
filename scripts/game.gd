extends Node2D

var time = 0

var world_time = 0
var world_state = "day"

var item_button_scene = preload("res://scenes/item_button.tscn")
var hovered_item = -1

@onready var player = $Player
@onready var hud = $CanvasLayer/Control
@onready var hotbar = hud.get_node("Hotbar")

func _process(delta: float) -> void:
	time += delta
	world_time += delta
	
	if world_state == "night":
		world_time += delta
	
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
			
	if world_state == "day":
		$NightSky.modulate.a /= 1.1
		hud.get_node("Time/HFlowContainer/Day").visible = true
		hud.get_node("Time/HFlowContainer/Day").value = 600 - world_time
		hud.get_node("Time/HFlowContainer/Night").visible = false
	elif world_state == "night":
		if $NightSky.modulate.a < 0.01:
			$NightSky.modulate.a = 0.01
		$NightSky.modulate.a /= 0.98
		hud.get_node("Time/HFlowContainer/Night").visible = true
		hud.get_node("Time/HFlowContainer/Night").value = 600 - world_time
		hud.get_node("Time/HFlowContainer/Day").visible = false
	
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
		

func _select_item_from_button(item_button: Node):
	if player.busy:
		return
	player.selected_item = item_button.get_meta("number")
	
func _item_button_mouse_entered(item_button: Node):
	hovered_item = item_button.get_meta("number")
	
func _item_button_mouse_exited(item_button: Node):
	hovered_item = -1
