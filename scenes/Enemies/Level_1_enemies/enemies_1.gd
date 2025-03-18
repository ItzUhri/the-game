extends RigidBody2D


@onready var game_manager_lvl_1: Node = %GManager_1

var speed: float = 200  
var direction: int = 1  
var sneaking = false
var is_in_kill_zone = false  
var player_reference: Node2D = null  

@onready var label: Label = $Label
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	label.hide()  


func _process(delta: float) -> void:
	apply_central_force(Vector2(speed * direction, 0))
	
	if position.x > 400:
		direction = -1
	elif position.x < 100:
		direction = 1

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
			game_manager_lvl_1.decrease_warning()
			
 
func _on_sound_area_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		print("Character is Sneaking")
		sprite_2d.animation = "idle"
		

func _on_kill_area_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		label.show()  
		is_in_kill_zone = true
		player_reference = body 

func _on_kill_area_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		label.hide() 
		is_in_kill_zone = false
		player_reference = null

func _kill_bot() -> void:
	if player_reference:
		print("Stealth Kill Activated!")
		if player_reference.has_method("play_stealth_kill_animation"):
			await player_reference.play_stealth_kill_animation()  
		sprite_2d.play("walking")  
		await sprite_2d.animation_finished  
		await get_tree().create_timer(0.5).timeout  
		queue_free()


func _on_pov_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		print("Alerted")


func _on_pov_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		print("they finding u")
		
