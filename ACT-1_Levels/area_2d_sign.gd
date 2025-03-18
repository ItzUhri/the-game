extends Area2D

@onready var message_label = $Label

func _ready() -> void:
	message_label.hide()


func _on_body_entered(body: Node2D) -> void:
	print("Detected: ", body.name)  # Check if the player is detected
	if body is CharacterBody2D:
		message_label.show()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		message_label.hide()
