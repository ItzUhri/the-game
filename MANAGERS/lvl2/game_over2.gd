extends Node

@onready var game_over: Panel = $Panel

var warning = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if warning == 0:
		get_tree().paused = true
		game_over.show()



func _on_restart_pressed() -> void:
	game_over.hide()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	game_over.hide()
	get_tree().quit()
	
func _on_menu_pressed() -> void:
	pass # Replace with function body.
