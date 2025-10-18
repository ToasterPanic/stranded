extends Node2D

var time = 0

var item_button_scene = preload("res://scenes/item_button.tscn")

@onready var player = $Player
@onready var hud = $CanvasLayer/Control
@onready var hotbar = hud.get_node("Hotbar")

func _process(delta: float) -> void:
	time += delta
	$Water.position.x = sin(time * 2) * 200
	$Water2.position.x = sin((time + 7) * 2.1) * 200
	
	var i = 0
	for n in player.inventory:
		var item_button = hotbar.get_node("Container").get_node("ItemButton" + str(i))
		
		if item_button and (item_button.get_meta("id") != n.id):
			item_button.queue_free()
			item_button = null
		
		if not item_button:
			item_button = item_button_scene.instantiate()
			hotbar.get_node("Container").add_child(item_button)
			
			item_button.name = "ItemButton" + str(i)
			item_button.connect("pressed", _select_item_from_button.bind(item_button))
			item_button.set_meta("number", i)
			item_button.set_meta("id", n.id)
			
			item_button.get_node("Texture").texture = load("res://textures/items/" + n.id + ".png")
			item_button.get_node("Keybind").text = "[" + str(i + 1) + "] "
			
			
			
		if i == player.selected_item:
			item_button.modulate = Color(1, 1, 1, 1)
		else:
			item_button.modulate = Color(1, 1, 1, 0.666)
			
		item_button.get_node("Amount").text = " " + str(n.amount)
		
		i += 1

func _select_item_from_button(item_button: Node):
	if player.busy:
		return
	player.selected_item = item_button.get_meta("number")
