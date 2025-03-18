extends Area2D

@export var area_camera: Camera2D  # The Camera inside this Area2D
@export var zoom_in_value: Vector2 = Vector2(0.5, 0.5)  # Zoom in level
@export var zoom_out_value: Vector2 = Vector2(0.8, 0.8)  # Default zoom level
@export var transition_duration: float = 1.0  # Smooth transition time

var player_camera: Camera2D = null  # Reference to the player's Camera2D
var original_zoom: Vector2  # Store player's original zoom

func _ready() -> void:
	await get_tree().process_frame  # Ensure cameras are set properly

	# Find the player's camera
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player_camera = player.get_node_or_null("Camera2D")
		if player_camera:
			player_camera.make_current()  # Ensure player camera is active
			area_camera.enabled = false  # Disable the Area2D camera

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and player_camera and area_camera:
		# Store the player's original zoom
		original_zoom = player_camera.zoom

		# Disable player camera movement
		player_camera.enabled = false  

		# Set Area Camera zoom to match the player's current zoom before transitioning
		area_camera.zoom = player_camera.zoom

		# Smoothly move camera position & activate Area2D camera
		_smooth_transition(area_camera, player_camera.position)
		area_camera.enabled = true
		area_camera.make_current()

		# Smoothly zoom in from the player's current zoom
		_zoom_camera(area_camera, zoom_in_value)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and area_camera and player_camera:
		# Smoothly zoom back to original zoom before switching cameras
		_zoom_camera(area_camera, original_zoom)

		await get_tree().create_timer(transition_duration).timeout  # Wait for zoom-out

		# Smoothly transition back to player camera
		_smooth_transition(player_camera, area_camera.position)
		player_camera.enabled = true
		player_camera.make_current()

func _smooth_transition(camera: Camera2D, target_position: Vector2) -> void:
	if camera:
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "position", target_position, transition_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _zoom_camera(camera: Camera2D, target_zoom: Vector2) -> void:
	if camera:
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", target_zoom, transition_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
