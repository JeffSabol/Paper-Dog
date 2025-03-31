extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed = 300
var jump_speed = -400.0
var is_jumping = false
var reset_position = position
var reset_velocity = velocity

@onready var reset_hit_area = $Area2D/CollisionPolygon2D.global_position
@onready var _animated_sprite = $AnimatedSprite2D
@onready var hit_box = $Area2D/CollisionPolygon2D

func _physics_process(delta):
	if is_jumping:
		$Area2D.monitoring = true
		$CollisionShape2D.disabled = false
		_animated_sprite.play("jump")
		velocity.y += gravity * delta
	else:
		$Area2D.monitoring = false
		$CollisionShape2D.disabled = true
		_animated_sprite.play("dirt")
		position = reset_position
		velocity = reset_velocity
		$Area2D/CollisionPolygon2D.global_position = reset_hit_area
	
	if is_on_floor():
		is_jumping = false
		
		
	move_and_slide()

func jump():
	velocity.y = jump_speed

func _on_jump_timer_timeout():
	is_jumping = true
	jump()

func _on_area_2d_body_entered(body):
	if body is Player:
		body.hurt()
