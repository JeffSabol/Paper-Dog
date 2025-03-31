extends Area2D

@onready var sprite = $Sprite2D

var new_sprite_texture = preload("res://Assets/Environment/FireHydrantUsed.png")

func _on_body_entered(body):
	if body is Player:
		body.pee()
		change_sprite_after_seconds(3)
		# Set the check point
		Global.set_checkpoint(body.global_position, get_tree().current_scene.scene_file_path)


func change_sprite_after_seconds(seconds):
	await get_tree().create_timer(seconds).timeout
	sprite.texture = new_sprite_texture
