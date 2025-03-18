extends Node

var warning = 3 


@onready var game_over_panel: Panel = $"../ui/GameOver/Panel"
@export var Warning : Array[Node]

func decrease_warning():
	warning -= 1
	print(warning)
	for W in 3:
		if (W < warning):
			Warning[W].show()
		else:
			Warning[W].hide()
	if(warning == 0):
		get_tree().paused = true
		game_over_panel.show()
