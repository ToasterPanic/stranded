extends Node2D

var time = 0
var action = null

func _process(delta: float) -> void:
	time += delta
	
	if action == "new_game":
		$CanvasLayer/Control/BlackFade.color.a += 1 * delta
		if $CanvasLayer/Control/BlackFade.color.a >= 1:
			get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		$CanvasLayer/Control/BlackFade.color.a /= 1.05
	
	$Camera2D.position.y /= 1.1
	$CanvasLayer/Control.position.y /= 1.1
	
	$Water.position.x = sin(time * 2) * 200
	$Water2.position.x = sin((time + 7) * 2.1) * 200
	
	

func _on_siege_pressed() -> void:
	OS.shell_open("https://siege.hackclub.com")

func _on_toaster_panic_pressed() -> void:
	OS.shell_open("https://owouw.us")


func _on_new_game_pressed() -> void:
	action = "new_game"
