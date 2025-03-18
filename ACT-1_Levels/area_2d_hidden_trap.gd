extends Area2D

@onready var hidden_trap = $TileMapLayer

func _ready() -> void:
	hidden_trap.show()
	
func _on_body_entered(body: Node2D) -> void:
	print("Detected: ", body.name)  # Check if the player is detected
	if body is CharacterBody2D:
		hidden_trap.hide()


func _on_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		hidden_trap.hide()
