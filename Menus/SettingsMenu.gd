# Jeff Sabol
# SettingsMenu.gd : The scripting behind the settings menu. Makes the buttons actually work and affect game.
extends Control

# Full Screen button textures
var full_screen_on = preload("res://Assets/Menu/Settings/Fullscreen.png")
var full_screen_off = preload("res://Assets/Menu/Settings/FullscreenOff.png")

# Difficulty button textures
var easy_button_normal = preload("res://Assets/Menu/Settings/Easy.png")
var medium_button_normal = preload("res://Assets/Menu/Settings/Medium.png")
var hard_button_normal = preload("res://Assets/Menu/Settings/Hard.png")

# Master Volume button textures
var master_volume_on = preload("res://Assets/Menu/Settings/MasterVolumeOn.png")
var master_volume_off = preload("res://Assets/Menu/Settings/MasterVolumeOff.png")

# Original master volume
var original_master_volume

# Speedrun button textures
var speed_run_on = preload("res://Assets/Menu/Settings/Speedrun Clock.png")
var speed_run_off = preload("res://Assets/Menu/Settings/Speedrun_Clock_Off.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	original_master_volume = AudioServer.get_bus_volume_db(0)
	# Fixes the difficulty button always being the easy texture upon opening the settings menu.
	match Global.current_difficulty:
		Global.DifficultyLevel.EASY:
			$ScrollContainer/VBoxContainer/DifficultyButton.texture_normal = easy_button_normal
		Global.DifficultyLevel.MEDIUM:
			$ScrollContainer/VBoxContainer/DifficultyButton.texture_normal = medium_button_normal
		Global.DifficultyLevel.HARD:
			$ScrollContainer/VBoxContainer/DifficultyButton.texture_normal = hard_button_normal
			
	if Global.config.get_value("sound", "master"):
		$ScrollContainer/VBoxContainer/MasterVolumeButton.texture_normal = master_volume_on
	else:
		$ScrollContainer/VBoxContainer/MasterVolumeButton.texture_normal = master_volume_off
		
	# Set the Speedrun timer texture
	if Global.config.get_value("counter", "speedrun"):
		$ScrollContainer/VBoxContainer/SpeedrunCounterButton.texture_normal = speed_run_on
	else:
		$ScrollContainer/VBoxContainer/SpeedrunCounterButton.texture_normal = speed_run_off
		
	# Set the Full Screen button texture
	if Global.config.get_value("display", "fullscreen"):
		$ScrollContainer/VBoxContainer/FullScreenButton.texture_normal = full_screen_on
	else:
		$ScrollContainer/VBoxContainer/FullScreenButton.texture_normal = full_screen_off
		pass
		
	#"display": {
		#"fullscreen": false,
	#},
	#"game": {
		#"difficulty": DifficultyLevel.HARD,
	#},
	#"counter" : {
		#"speedrun": false,
	#},
	#"sound" : {
		#"master": true,
	#}

func _on_exit_button_pressed():
	$ButtonSound.play()
	
	# Revert to the previously saved settings
	AudioServer.set_bus_volume_db(0, original_master_volume)
	Global.load_settings()
	Global.apply_settings()
	hide()
	
	# Restore focus to the main menu buttons
	get_parent().restore_focus()

func _on_reset_button_pressed():
	$ButtonSound.play()
	
	# Reset all settings to their default values
	Global.config = ConfigFile.new()
	for section in Global.default_settings.keys():
		for key in Global.default_settings[section]:
			Global.config.set_value(section, key, Global.default_settings[section][key])
	Global.apply_settings()
	
	_ready()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
		
func _on_save_button_pressed():
	Global.config.save("res://settings.cfg")
	$ButtonSound.play()
	hide()
	
	# Restore focus to the main menu buttons
	get_parent().restore_focus()

func _on_full_screen_button_pressed():
	$ButtonSound.play()
	
	# Toggle fullscreen mode and update the settings
	var fullscreen = not Global.config.get_value("display", "fullscreen", Global.default_settings["display"]["fullscreen"])
	
	# Set the texture
	if Global.config.get_value("display", "fullscreen"):
		$ScrollContainer/VBoxContainer/FullScreenButton.texture_normal = full_screen_off
		Global.config.set_value("display", "fullscreen", fullscreen)
	else:
		$ScrollContainer/VBoxContainer/FullScreenButton.texture_normal = full_screen_on
		Global.config.set_value("display", "fullscreen", fullscreen)
	Global.apply_settings()

func _on_difficulty_button_pressed():
	$ButtonSound.play()
	
	Global.current_difficulty = (Global.current_difficulty + 1) % 3 # enum DifficultyLevel { EASY, MEDIUM, HARD }
	
	match Global.current_difficulty:
		Global.DifficultyLevel.EASY:
			$ScrollContainer/VBoxContainer/DifficultyButton.texture_normal = easy_button_normal
		Global.DifficultyLevel.MEDIUM:
			$ScrollContainer/VBoxContainer/DifficultyButton.texture_normal = medium_button_normal
		Global.DifficultyLevel.HARD:
			$ScrollContainer/VBoxContainer/DifficultyButton.texture_normal = hard_button_normal
	Global.config.set_value("game", "difficulty", Global.current_difficulty)
	Global.config.save("res://settings.cfg")

func _on_speedrun_counter_button_pressed() -> void:
	$ButtonSound.play()
	
	# Toggle the speedrun counter in the game's HUD
	# Flip the current speedrun value upon being pressed
	var speedrun_counter = not Global.config.get_value("counter", "speedrun", Global.default_settings["counter"]["speedrun"])
	
	# Set the texture
	if Global.config.get_value("counter", "speedrun"):
		$ScrollContainer/VBoxContainer/SpeedrunCounterButton.texture_normal = speed_run_off
		Global.config.set_value("counter", "speedrun", speedrun_counter)
	else:
		$ScrollContainer/VBoxContainer/SpeedrunCounterButton.texture_normal = speed_run_on
		Global.config.set_value("counter", "speedrun", speedrun_counter)
	Global.apply_settings()

func _on_master_volume_button_pressed() -> void:
	$ButtonSound.play()
	
	# Toggle mute
	if Global.config.get_value("sound", "master"):
		$ScrollContainer/VBoxContainer/MasterVolumeButton.texture_normal = master_volume_off
		AudioServer.set_bus_volume_db(0, -256.0)
		Global.config.set_value("sound", "master", false)
	else:
		AudioServer.set_bus_volume_db(0, 0)
		$ScrollContainer/VBoxContainer/MasterVolumeButton.texture_normal = master_volume_on
		Global.config.set_value("sound", "master", true)
	Global.apply_settings()
