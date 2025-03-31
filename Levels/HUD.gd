# Jeff Sabol
# Scripting for the player's HUD on-screen. Controls the bone value and time for a level.
extends Control

var time_left = 170

func _process(delta: float) -> void:
	if (Global.config.get_value("counter", "speedrun")):
		$SpeedrunCounter.show()
	else:
		$SpeedrunCounter.hide()
	$SpeedrunCounter.text = get_formatted_time()

func _ready():
	# Initialize the values for bones, display time, and level time.
	$BoneCounter/Bones.text = str(Global.total_bones)
	$TimeCounter/Seconds.text = str(time_left)
	Global.total_time = time_left


func get_formatted_time() -> String:
	var milliseconds = int(Global.elapsed_time) % 1000
	var total_seconds = int(Global.elapsed_time / 1000)
	var seconds = total_seconds % 60
	var minutes = (total_seconds / 60) % 60
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]


func _on_bone_picked_up():
	_ready()

func updateTimer():
	time_left = Global.total_time
	time_left -= 1
	Global.total_time = time_left
	$TimeCounter/Seconds.text = str(time_left)
	
	# Play the time running out music
	if time_left == 10:
		var audio_player = AudioStreamPlayer.new()
		$"../../../Level Music".stream = load("res://Assets/Audio/Gameplay Music/Time_Running_Out_Music.wav")
		$"../../../Level Music".play()
	
	if time_left <= 0:
		Global.has_collar = true
		Global.total_lives -= 1
		
		if Global.total_lives > 0:
			# Respawn at the check point
			print("DEBUG: Global.has_checkpoint(): "+str(Global.has_checkpoint()))
			if Global.has_checkpoint():
				Global._deferred_respawn_at_checkpoint()
			else:
				# Restart the current level
				Global.level_count -= 1
				Global.level_path = "res://Levels/level_" + str(Global.level_count) + ".tscn"
				Global.goto_next_level()
		else:
			# Reset the lives depending on the difficulty
			Global.total_lives = 5
			# Restart at level 1
			Global._deferred_goto_scene("res://Menus/GameOver.tscn")

# Currently set to one second
func _on_level_timer_timeout():
	updateTimer()

# Update to indicate that the player is holding the newspaper.
func show_newspaper_text():
	$Newspaper.show()
