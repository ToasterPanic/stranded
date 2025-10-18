extends Sprite2D

var fishing = false
var reeling = false
var lastChance = 0
var tension = 50
var validInputs = [
	"move_right",
	"move_left",
	"move_up",
	"move_down"
]
var currentInput = "move_right"

@onready var world = get_parent()
@onready var camera = world.get_node("Camera")
@onready var player = world.get_node("Player")
@onready var hud = world.get_node("CanvasLayer/Control")
@onready var bobber = $Bobber

func _process(delta: float) -> void:
	if fishing:
		camera.zoom.x += (2 - camera.zoom.x) * 0.1
		camera.zoom.y = camera.zoom.x
		camera.position = Vector2i(bobber.position) + (DisplayServer.window_get_size() / 2)
		camera.position.x -= DisplayServer.window_get_size().x / 4
		bobber.visible = true
		
		lastChance += delta
		
		
				
		if reeling:
			if lastChance > 1.25:
				lastChance = 0
				currentInput = validInputs[randi_range(0, validInputs.size() - 1)]
				
			var do_it = true
			for n in validInputs:
				if currentInput == n:
					continue
				if Input.is_action_pressed(n):
					do_it = false 
			
				
			if Input.is_action_pressed(currentInput) and do_it:
				bobber.linear_velocity.x = -128
				tension += 66 * delta
			else:
				tension -= 45 * delta
				
			if tension < 0:
				
				fishing = false
				player.busy = false
				player.can_move = true
				return
				
			if tension > 100:
				
				fishing = false
				player.busy = false
				player.can_move = true
				return
			
			hud.get_node("Tension/ProgressBar").value = tension
			hud.get_node("Tension/Label").text = currentInput
		else:
			if lastChance > 4:
				lastChance = 0
				if randi_range(0, 0) == 0:
					print("TEST")
					reeling = true
					tension = 50
					
					hud.get_node("Tension").visible = true
	else:
		hud.get_node("Tension").visible = false
		camera.zoom.x += (1 - camera.zoom.x) * 0.1
		camera.zoom.y = camera.zoom.x
		camera.position = Vector2(0, 0)
		bobber.visible = false
		
	bobber.rotation = 0
	bobber.get_node("Sprite").position.y = sin(world.time * 2) * 5
	
	bobber.get_node("Line2D").points[1] = bobber.position * -1
	bobber.get_node("Line2D").points[1] -= Vector2(-10, 32)
	bobber.get_node("Line2D").points[0].y = -32 + $Bobber/Sprite.position.y
		
	$Label.visible = false
	for n in $Area.get_overlapping_bodies():
		if n.get_name() == "Bobber":
			if reeling:
				reeling = false
				
				var chance = randi_range(0, 2)
				var loot_table = null
				
				if chance == 0:
					loot_table = Global.loot_tables["fish_fishing"]
				else:
					loot_table = Global.loot_tables["gear_fishing"]
				
				var item = loot_table[randi_range(0, loot_table.size() - 1)]
				
				if not item.has("amount"):
					item.amount = 1
				
				player.add_item(item.id, item.amount)
				
				fishing = false
				player.busy = false
				player.can_move = true
		elif n.get_name() == "Player":
			$Label.visible = true
			if Input.is_action_just_pressed("interact"):
				if fishing:
					break
					
				hud.get_node("Tension").visible = false
				
				fishing = true
				reeling = false
				lastChance = -2
				
				n.busy = true
				n.can_move = false
				
				PhysicsServer2D.body_set_state(
					bobber.get_rid(),
					PhysicsServer2D.BODY_STATE_TRANSFORM,
					Transform2D.IDENTITY.translated(global_position)
				)
				bobber.linear_velocity = Vector2(0, 0)
				bobber.apply_impulse(Vector2(480, -480))
