extends CharacterBody2D

var speed = 100
var moving_direction = 1  # Determines the initial moving direction, 1 for right and -1 for left
var gravity = 400  # Gravity applied to the enemy
var ray_cast: RayCast2D  # RayCast for detecting front collisions
var ray_cast2: RayCast2D  # Second RayCast for additional front collision detection
var top_ray_cast: RayCast2D  # RayCast for detecting collisions from above
var stomp_detector: Area2D  # Area2D for detecting stomps
var death_sounds = [
	preload("res://Assets/Audio/Gameplay SFX/MoleDeath1.wav"),
	preload("res://Assets/Audio/Gameplay SFX/MoleDeath2.wav"),
	preload("res://Assets/Audio/Gameplay SFX/MoleDeath3.wav"),
	preload("res://Assets/Audio/Gameplay SFX/MoleDeath4.wav"),
	preload("res://Assets/Audio/Gameplay SFX/MoleDeath5.wav"),
]

func _ready():
	ray_cast = $RayCast2D
	ray_cast.enabled = true
	ray_cast2 = $RayCast2D2
	ray_cast2.enabled = true
	stomp_detector = $StompDetector 

	$AnimatedSprite2D.play()
	$AnimatedSprite2D.scale.x *= -1

func _physics_process(delta):
	# Apply horizontal movement based on the direction
	velocity.x = speed * moving_direction

	# Apply gravity to the vertical velocity
	velocity.y += gravity * delta

	# Check for RayCast collisions with the player
	if ray_cast.is_colliding() or ray_cast2.is_colliding():
		var collider = ray_cast.get_collider()
		var collider2 = ray_cast2.get_collider()
		if collider and collider.name == "Player":
			if $StunTimer.is_stopped():
				$StunTimer.start()
				collider.hurt()  # Apply damage to the player if collided
				if !collider.is_invincible:
					Global.total_time = 0
				enter_death_state()
		if collider2 and collider2.name == "Player":
			if $StunTimer.is_stopped():
				$StunTimer.start()
				collider2.hurt()  # Apply damage to the player if collided
				if !collider2.is_invincible:
					Global.total_time = 0
				enter_death_state()
	# Move and slide with the current velocity
	move_and_slide()

	# Check if the enemy has hit an obstacle and reverse direction
	if velocity.x == 0:
		moving_direction *= -1
		velocity.x = 10 * moving_direction
		ray_cast.scale.x *= -1  # Flip the RayCast direction
		$AnimatedSprite2D.scale.x *= -1  # Flip the sprite direction

func enter_death_state(): # TODO refactor to be enter_death_state()
	var random_sound_index = randi() % death_sounds.size()
	$AnimatedSprite2D.animation = "death"
	$Death.stream  = death_sounds[random_sound_index]
	$Death.play()
	
	# Change the collision layer and mask
	await get_tree().create_timer(0.1).timeout
	collision_layer = 0  # Set to a layer that doesn't interact with platforms
	collision_mask = 0  # Set to a mask that doesn't interact with platforms

	# Optionally increase gravity or apply a downward force for immediate fall effect
	gravity = 1000

	# Wait for a moment before removing the enemy from the scene
	await get_tree().create_timer(3.0).timeout
	queue_free()  # Remove the enemy from the scene

func _on_stomp_detector_body_entered(body):
	if body.name == "Player":  # Check if the player entered the area
		enter_death_state()
