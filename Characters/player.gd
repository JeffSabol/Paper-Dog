# Jeff Sabol
# player.gd : Uses scripting to breathe life into the player node.
extends CharacterBody2D
class_name Player

# Node variables
@onready var player_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var crawl_raycast_1 = $CrawlRayCast1
@onready var crawl_raycast_2 = $CrawlRayCast2
@onready var pee_timer = $PeeTimer

# Constants
const SPEED = 180.0 # The normal speed of the player
const CRAWL_SPEED = 55.0
const JUMP_VELOCITY = -340.0
const STANDING_COLLISION_Y_POS = 11 # Offset for standing collision shape
const CROUCHING_COLLISION_Y_POS = 17 # Offset for crouching collision shape
const ACCELERATION = 6.0 # The acceleration rate for smooth movement
const BOOSTED_SPEED = 250.0  # Increased speed when Shift is held
const CROUCHING_FALL_GRAVITY_MULTIPLIER = 1.5  # Added constant for crouching fall gravity multiplier


# Enums and variables
enum PlayerState {STANDING, WALKING, CRAWL, JUMPING, FALLING, PEEING, HURT} 
var state = PlayerState.STANDING
var is_crouching = false 
var stuck_under_object = false
var is_peeing = false
@export var is_hurt = false
@export var is_invincible = false
var standing_collision_shape = preload("res://Characters/CollisionBoxes/player.tres")
var crouching_collision_shape = preload("res://Characters/CollisionBoxes/playerCROUCHING.tres")

# Gravity and jump buffer
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_gravity_multiplier = 1.75
var jump_buffer_duration = 0.2
var jump_buffer_timer = 0.0
var jump_input_received = false

# Timed jump stuff
var jump_force = 300.0
var max_jump_time = 1.0
var current_jump_time = 0.0

# Jump input handling
# Stops the user from holding down jump on the controller to spam
var controller_jump_pressed = false

# Coyote Jump
var coyote_time_duration = 0.10
var coyote_time_timer = 0.0
var can_jump_during_coyote_time = false

# Prevent crouching in tunnel stuck glitch
var is_in_tunnel = false

# Physics processing
func _physics_process(delta):
	if !$InvincibilityTimer.is_stopped():
		is_invincible = true
	update_jump_buffer(delta)
	handle_jump_input()
	handle_gravity_and_state(delta)
	handle_input_and_movement(delta)
	update_coyote_time(delta)
	
	if state == PlayerState.JUMPING and (Input.is_action_pressed("ui_up") or Input.is_joy_button_pressed(0, JOY_BUTTON_B)) or Input.is_action_pressed("Jump") and current_jump_time < max_jump_time:
		velocity.y -= jump_force * delta
		current_jump_time += delta

# Jump input handling
func handle_jump_input():
	if is_peeing or is_hurt:
		return

	var jump_button_just_pressed = Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("Jump")
	var controller_jump_just_pressed = Input.is_joy_button_pressed(0, JOY_BUTTON_B) and not controller_jump_pressed

	if (jump_button_just_pressed or controller_jump_just_pressed) and not is_peeing and not is_hurt:
		if is_on_floor() or can_jump_during_coyote_time:
			perform_jump()
			coyote_time_timer = 0
			can_jump_during_coyote_time = false
		else:
			jump_input_received = true
			jump_buffer_timer = jump_buffer_duration
			
		controller_jump_pressed = true
	elif jump_input_received and is_on_floor():
		perform_jump()
		jump_input_received = false
		jump_buffer_timer = 0
		
		if not Input.is_action_pressed("ui_up") and not Input.is_joy_button_pressed(0, JOY_BUTTON_B):
			jump_input_received = false

# Jump buffer handling
func update_jump_buffer(delta):
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		if jump_buffer_timer <= 0:
			jump_input_received = false

# Gravity and state management
func handle_gravity_and_state(delta):
	if not is_on_floor():
		apply_gravity(delta)
		update_airborne_state()
	else:
		update_ground_state()

# Input and movement handling
func handle_input_and_movement(delta):
	var direction = get_input_direction()
	move_character(direction, delta)
	handle_crouch_logic()

# Apply gravity to the player
func apply_gravity(delta):
	if velocity.y > 0:  # Character is falling
		if is_crouching:
			velocity.y += gravity * fall_gravity_multiplier * CROUCHING_FALL_GRAVITY_MULTIPLIER * delta
		else:
			velocity.y += gravity * fall_gravity_multiplier * delta
	else:
		velocity.y += gravity * delta

# Update the player's state while airborne
func update_airborne_state():
	if velocity.y < 0 and not is_peeing and not is_hurt:
		state = PlayerState.JUMPING
	elif velocity.y > 0.1 and not is_peeing and not is_hurt:
		state = PlayerState.FALLING

# Coyote jump time tracking
func update_coyote_time(delta):
	if is_on_floor():
		coyote_time_timer = coyote_time_duration
		can_jump_during_coyote_time = true
	elif coyote_time_timer > 0:
		coyote_time_timer -= delta
	else:
		can_jump_during_coyote_time = false

# Update the player's state while on the ground
func update_ground_state():
	if is_on_floor():
		if is_crouching and not Input.is_action_pressed("ui_down") and above_head_is_empty():
			uncrouch()
	if velocity.x == 0 and not is_crouching and not is_peeing and not is_hurt:
		state = PlayerState.STANDING
	elif velocity.x != 0 and is_crouching and not is_peeing and not is_hurt:
		state = PlayerState.CRAWL
	elif not is_peeing and not is_hurt:
		state = PlayerState.WALKING

# Get input direction
func get_input_direction() -> int:
	if is_peeing or is_hurt:  # Ignore movement input if peeing
		return 0
	if state != PlayerState.PEEING and state != PlayerState.HURT:
		var joystick_direction = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		if abs(joystick_direction) > 0.2:
			return sign(joystick_direction)
		return Input.get_axis("ui_left", "ui_right")
	return 0

func move_character(direction: int, delta: float):
	var target_speed = SPEED
	if (Input.is_action_pressed("ui_shift") or Input.is_joy_button_pressed(0, JOY_BUTTON_A) or Input.is_joy_button_pressed(0, JOY_BUTTON_LEFT_SHOULDER)) and not is_crouching:
		target_speed = BOOSTED_SPEED

	var target_velocity_x = direction * (target_speed if state != PlayerState.CRAWL else CRAWL_SPEED)
	var lerp_factor = ACCELERATION * delta

	# Smoother speed transition from run to crawl
	if state == PlayerState.CRAWL and abs(velocity.x) > CRAWL_SPEED:
		lerp_factor *= 0.65

	velocity.x = lerp(velocity.x, target_velocity_x, lerp_factor)
	update_animations()
	move_and_slide()


# Handle the crouch logic
func handle_crouch_logic():
	if Input.is_action_just_pressed("ui_down") and not is_in_tunnel:
		crouch()
	elif Input.is_action_just_released("ui_down"):
		if above_head_is_empty() and is_on_floor():
			uncrouch()
		elif not stuck_under_object:
			stuck_under_object = true
	if stuck_under_object and above_head_is_empty() and not Input.is_action_pressed("ui_down"):
		uncrouch()
		stuck_under_object = false

# Check if the space above the player's head is empty
func above_head_is_empty() -> bool:
	return not crawl_raycast_1.is_colliding() and not crawl_raycast_2.is_colliding()

# Update animations based on player state
func update_animations():
	#if is_peeing:
	#	player_sprite.play("pee_collar")

	# Update state based on velocity
	if abs(velocity.x) < 10 and not is_peeing and not is_hurt:
		if velocity.y < 0: # negative velocity means you are going upgit 
			state = PlayerState.JUMPING
		elif velocity.y > 0:
			state=PlayerState.FALLING
		else:
			state = PlayerState.STANDING

	match state:
		PlayerState.STANDING:
			if Global.has_collar:
				player_sprite.play("idle_collar")
			else:
				player_sprite.play("idle")
		PlayerState.WALKING:
			if Global.has_collar:
				player_sprite.play("walk_collar")
			else:
				player_sprite.play("walk")
		PlayerState.JUMPING:
			if Global.has_collar:
				if (player_sprite.animation != "jump_collar"):
					player_sprite.play("jump_collar")
			else:
				if (player_sprite.animation != "jump"):
					player_sprite.play("jump")
		PlayerState.FALLING:
			if Global.has_collar:
				player_sprite.play("fall_collar")
			else:
				player_sprite.play("fall")
		PlayerState.PEEING:
			if Global.has_collar:
				player_sprite.play("pee_collar")
			else:
				player_sprite.play("pee")
		PlayerState.HURT:
			if is_crouching:
				if is_hurt:
					player_sprite.play("crawl_hurt")
				else:
					if Global.has_collar:
						player_sprite.play("crawl_collar")
					else:
						player_sprite.play("crawl")
			else:
				player_sprite.play("hurt")

	if is_crouching and player_sprite.animation != "crawl" and !is_hurt:
		if Global.has_collar:
			player_sprite.play("crawl_collar")
		else:
			player_sprite.play("crawl")
		
	# Flip sprite based on movement direction
	player_sprite.flip_h = velocity.x < 0

# Crouch functionality
func crouch():
	if state == PlayerState.PEEING or state == PlayerState.HURT or state == PlayerState.CRAWL:
		return
	state = PlayerState.CRAWL
	if is_crouching:
		return
	is_crouching = true
	collision_shape.shape = crouching_collision_shape
	collision_shape.position.y = CROUCHING_COLLISION_Y_POS

# Uncrouch functionality
func uncrouch():
	if state == PlayerState.PEEING or state == PlayerState.HURT or not is_crouching:
		return
	if is_on_floor():
		is_crouching = false
		state = PlayerState.STANDING  # Return to standing state when uncrouching
		collision_shape.shape = standing_collision_shape
		collision_shape.position.y = STANDING_COLLISION_Y_POS

# Pee functionality
func pee():
	if is_crouching:
		is_crouching = false
		update_collision_shape_for_standing()
	is_peeing = true
	state = PlayerState.PEEING
	player_sprite.play("pee")
	pee_timer.start(3)

# Perform jump action
func perform_jump():
	$Jump.play()
	velocity.y = -jump_force
	state = PlayerState.JUMPING
	current_jump_time = 0.0

# Hurt functionality
func hurt():
	state = PlayerState.HURT
	if Global.has_collar == true:
		$InvincibilityTimer.start()
		is_invincible = true
	Global.has_collar = false
	is_hurt = true
	pee_timer.start(0.5)
	$Hurt.play()

# Timeout handling for pee timer
func _on_pee_timer_timeout():
	is_peeing = false
	is_hurt = false
	if above_head_is_empty():
		is_crouching = false
		update_collision_shape_for_standing()
	state = PlayerState.STANDING
	
# Update collision shape for standing
func update_collision_shape_for_standing():
	collision_shape.shape = standing_collision_shape
	collision_shape.position.y = STANDING_COLLISION_Y_POS
	
func _on_invincibility_timer_timeout() -> void:
	is_invincible = false

func _on_no_duck_zone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_in_tunnel = true

func _on_no_duck_zone_body_exited(body: Node2D) -> void:
	is_in_tunnel = false
