extends Area2D

@onready var sprite = $Sprite2D

func _on_body_entered(body):
	if body is Player:
		Global.goto_scene("res://Menus/EndOfLevel.tscn")
