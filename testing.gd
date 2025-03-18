extends CharacterBody2D

const SPEED = 400.0
const SNEAK_SPEED = 150.0
const JUMP_VELOCITY = -450.0
const WALL_JUMP_COOLDOWN = 0.2
const DASH_SPEED = 600.0
const DASH_DURATION = 0.3
const DASH_COOLDOWN = 1.0	
const KUNAI_COOLDOWN = 1.0
const COYOTE_TIME = 0.15  

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_left: RayCast2D = $RaycastLeft
@onready var raycast_right: RayCast2D = $RaycastRight

var jump_count = 0
var is_wall_hanging = false
var can_wall_jump = true
var wall_jump_timer = 0.0
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var kunai_cooldown_timer = 0.0
var last_facing_direction := Vector2.RIGHT
var wall_direction = 0
var coyote_timer = 0.0

# Hostage interaction
var can_interact_with_hostage := false
var hostage_reference: Node2D = null

func _physics_process(delta: float) -> void:
	# Update cooldowns
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	if kunai_cooldown_timer > 0:
		kunai_cooldown_timer -= delta
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
		if wall_jump_timer <= 0:
			can_wall_jump = true
	if coyote_timer > 0:
		coyote_timer -= delta
	
	# Dash logic
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	# Apply gravity
	if not is_on_floor() and not is_wall_hanging and not is_dashing:
		velocity += get_gravity() * delta
	
	# Handle wall hanging
	if (raycast_left.is_colliding() or raycast_right.is_colliding()) and not is_on_floor():
		is_wall_hanging = true
		velocity = Vector2.ZERO
		sprite_2d.animation = "wall_hang"
		wall_direction = 1 if raycast_left.is_colliding() else -1
	elif is_wall_hanging and not (raycast_left.is_colliding() or raycast_right.is_colliding()):
		is_wall_hanging = false
	
	# Reset jump on landing
	if is_on_floor():
		jump_count = 0
		can_wall_jump = true
		coyote_timer = COYOTE_TIME  
	
	# Handle jump mechanics with coyote time
	if Input.is_action_just_pressed("ui_accept"):
		var direction := Input.get_axis("ui_left", "ui_right")
		if is_wall_hanging and can_wall_jump and direction == wall_direction:
			velocity.y = JUMP_VELOCITY
			velocity.x = SPEED * wall_direction
			is_wall_hanging = false
			can_wall_jump = false
			wall_jump_timer = WALL_JUMP_COOLDOWN
			jump_count = 1
		elif jump_count < 2 or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			coyote_timer = 0  # Disable coyote time after jumping
	
	# Dash input
	if Input.is_action_just_pressed("ui_dash") and not is_dashing and dash_cooldown_timer <= 0:
		_start_dash(Input.get_axis("ui_left", "ui_right"))
	
	# Sneak and movement handling
	var is_sneaking := Input.is_action_pressed("ui_sneak")
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0 and not is_wall_hanging and not is_dashing:
		velocity.x = direction * (SNEAK_SPEED if is_sneaking else SPEED)
		last_facing_direction = Vector2.RIGHT if direction > 0 else Vector2.LEFT
		sprite_2d.flip_h = direction < 0
		sprite_2d.animation = "sneaking" if is_sneaking else "running"
	elif not is_dashing:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and not is_wall_hanging:
			sprite_2d.animation = "idle"
	
	# Falling animation
	if not is_on_floor() and not is_wall_hanging and not is_dashing:
		sprite_2d.animation = "falling" if velocity.y > 0 else "jump"
	
	# Move character
	move_and_slide()
	

	
	# Interact with hostage
	if Input.is_action_just_pressed("ui_release") and can_interact_with_hostage and hostage_reference:
		hostage_reference.release_hostage()

func _start_dash(direction: float) -> void:
	if direction == 0:
		direction = last_facing_direction.x
	if direction != 0 and not is_wall_hanging:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		velocity.x = direction * DASH_SPEED
		velocity.y = 0
		sprite_2d.animation = "dash"
