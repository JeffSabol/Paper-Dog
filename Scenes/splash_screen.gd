extends Control

@onready var dog_logo = $DogLogo
@onready var label = $Studio
@onready var background = $B0RKED

func _ready():
	# Start fully transparent
	dog_logo.modulate.a = 0.0
	label.modulate.a = 0.0
	
	var tween1 = get_tree().create_tween()
	
	# Initial position of the background
	var start_pos = background.position
	var end_pos = start_pos + Vector2(0, 50)
	# Background slowly moves down in parallel
	tween1.parallel().tween_property(background, "position", end_pos, 5)
	
	var tween2 = get_tree().create_tween()
	
	# Smooth fade-in only
	tween2.set_trans(Tween.TRANS_SINE)
	tween2.set_ease(Tween.EASE_OUT)

	tween2.tween_property(dog_logo, "modulate:a", 1.0, 1.2)
	tween2.tween_interval(0.2)
	tween2.tween_property(label, "modulate:a", 1.0, 0.8)


	# Wait a bit before continuing
	await get_tree().create_timer(4.0).timeout
	fade_out_and_continue()

func fade_out_and_continue():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(dog_logo, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.5)
	await tween.finished

	Global._deferred_goto_scene("res://Menus/MainMenu.tscn")
	#Global._deferred_goto_scene("res://Scenes/Newgrounds.tscn")
