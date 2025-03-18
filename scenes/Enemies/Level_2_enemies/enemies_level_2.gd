extends RigidBody2D


@onready var game_manager_lvl_2: Node = %GManager_2

var speed: float = 200  
var direction: int = 1  
var sneaking = false
var is_in_kill_zone = false  # Track if player is in kill area
var player_reference: Node2D = null  # Store player reference

@onready var label: Label = $Label
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	label.hide()  # Hide the label at the start

func _process(delta: float) -> void:
	# Apply force to move left and right
	apply_central_force(Vector2(speed * direction, 0))

	# Change direction when reaching a boundary
	if position.x > 400:
		direction = -1
	elif position.x < 100:
		direction = 1

	# Handle killing action
	if is_in_kill_zone and Input.is_action_just_pressed("ui_kill") and player_reference:
		_kill_bot()

func _on_sound_area_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		var player_sneaking = Input.is_action_pressed("ui_sneak")
		if player_sneaking:
			print("Character is Sneaking")
			sprite_2d.animation = "idle"
		else:
			print("Alert")
			sprite_2d.animation = "Alerted"
			game_manager_lvl_2.decrease_warning()
			
 
func _on_sound_area_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		print("Character is Sneaking")
		sprite_2d.animation = "idle"
		

func _on_kill_area_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		label.show()  # Show "Press Kill" label
		is_in_kill_zone = true
		player_reference = body  # Store reference to player

func _on_kill_area_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		label.hide()  # Hide label when player leaves
		is_in_kill_zone = false
		player_reference = null

func _kill_bot() -> void:
	print("Bot eliminated!")
	sprite_2d.animation = "die"
	await sprite_2d.animation_finished
	queue_free()  


func _on_pov_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		print("Alerted")


func _on_pov_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		print("they finding u")
