extends Area2D

@export var camera: Camera2D
@export var zoom_in_value: Vector2 = Vector2(2, 2)  # Target zoom level
@export var zoom_out_value: Vector2 = Vector2(0.7, 0.7)  # Default zoom level
@export var zoom_duration: float = 1  # Time for smooth transition

var original_offset: Vector2  # Stores original camera offset

func _ready() -> void:
	if camera:
		original_offset = camera.offset  # Save initial offset

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:  # Check if the player is a CharacterBody2D
		_zoom_camera(zoom_in_value)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:  # Restore original zoom when leaving
		_zoom_camera(zoom_out_value)

func _zoom_camera(target_zoom: Vector2) -> void:
	if camera:
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", target_zoom, zoom_duration)

		# Adjust camera offset to keep it in the same position
		tween.tween_property(camera, "offset", original_offset, zoom_duration)
