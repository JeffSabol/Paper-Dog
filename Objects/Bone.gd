extends Area2D

signal bone_picked_up

var collected := false
var player: CharacterBody2D = null
var pull_speed := 300.0
var scale_speed := 2.0
var min_distance := 12.0
var max_pull_speed := 1000.0

func _on_body_entered(body):
	if collected: return
	if body is Player:
		collected = true
		player = body
		$Pickup.play()
		$CollisionShape2D.disabled = true

func _process(delta):
	if collected and player:
		# Accelerate with easing
		pull_speed = clamp(pull_speed + 500.0 * delta, 300.0, max_pull_speed)

		# Movement and scale
		var target_pos = player.global_position
		global_position = global_position.move_toward(target_pos, pull_speed * delta)
		scale = scale.move_toward(Vector2(0.001, 0.001), delta * scale_speed)

		# Add a soft spin
		rotation += 5.0 * delta

		# Optional: fade out
		modulate.a = lerp(modulate.a, 0.0, delta * 4)

		# Finish when close
		if global_position.distance_to(target_pos) <= min_distance:
			_finalize_pickup()

func _finalize_pickup():
	self.visible = false
	Global.total_bones += 1
	bone_picked_up.emit()
	queue_free()
