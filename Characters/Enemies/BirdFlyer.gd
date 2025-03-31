extends CharacterBody2D

var speed = 100
var moving_direction = -1  # Determines the initial moving direction, 1 for right and -1 for left
var attack_zone: CollisionPolygon2D # Sharp beak hurts
var attack_zone_polygon
var mirrored_points = []
var bird_body: CollisionPolygon2D # Physics
var is_dead: bool = false
# Birds shall defy gravity until killed, then fall to the ground.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attack_zone_enabled = true # Added so that the bird can't attack more than once.
var death_sounds = [
	preload("res://Assets/Audio/Gameplay SFX/BirdDeath1.wav"),
	preload("res://Assets/Audio/Gameplay SFX/BirdDeath2.wav"),
	preload("res://Assets/Audio/Gameplay SFX/BirdDeath3.wav"),
	preload("res://Assets/Audio/Gameplay SFX/BirdDeath4.wav"),
]

func _ready():
	$AnimatedSprite2D.play()
	attack_zone = $Area2D/AttackZone
	attack_zone_polygon = attack_zone.polygon

func _physics_process(delta):
	if is_dead:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.x = 0
		move_and_slide()
		return

	# Apply horizontal movement based on the direction
	velocity.x = speed * moving_direction
	move_and_slide()

	# Match bird to direction.
	if velocity.x > 0:
		update_direction(1)
		$AnimatedSprite2D.play("fly")
	elif velocity.x < 0:
		update_direction(-1)
		$AnimatedSprite2D.play("fly")
	elif velocity.x == 0:
		$AnimatedSprite2D.pause()
		moving_direction *= -1

func update_direction(direction):
	moving_direction = direction
	$Body.scale.x = -direction
	$Area2D/AttackZone.scale.x = -direction
	$AnimatedSprite2D.scale.x = -direction

	# Mirror attack_zone CollisionPolygon2D horizontally if needed
	if direction == 1:
		mirror_polygon()

func mirror_polygon():
	var mirrored_polygon = []
	for vertex in attack_zone_polygon:
		var mirrored_vertex = Vector2(-vertex.x, vertex.y)
		mirrored_polygon.append(mirrored_vertex)
	attack_zone.polygon = mirrored_polygon

func _on_body_entered(body):
	if body is Player && attack_zone_enabled:
		attack_zone_enabled = false
		body.hurt()
		die()

func die():
	is_dead = true # Adds gravity
	$AnimatedSprite2D.play("dead")
	# Play a death sound
	var random_sound_index = randi() % death_sounds.size()
	$Death.stream  = death_sounds[random_sound_index]
	$Death.play()
	await get_tree().create_timer(2.5).timeout
	queue_free()  # Remove the enemy from the scene
