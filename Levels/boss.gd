extends CharacterBody2D

@export var speed := 100.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var direction := 1

@onready var sprite := $AnimatedSprite2D
@onready var collision_polygon := $CollisionPolygon2D
@onready var area_collision := $Area2D/CollisionShape2D

func _physics_process(delta):
	velocity.y += gravity * delta

	# Move left or right
	velocity.x = direction * speed

	move_and_slide()

	# Flip direction on wall collision
	if is_on_wall():
		direction *= -1
		flip_components()

func flip_components():
	sprite.flip_h = (direction == -1)

	collision_polygon.scale.x *= -1

	area_collision.scale.x *= -1
