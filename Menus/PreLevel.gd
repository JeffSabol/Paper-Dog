# Jeff Sabol
# Controls the UI for the pre-level screen. Mainly for selecting the powerups.
# Support for all screen sizes
extends Control

var current_selection
enum powerup {NONE, BURGER, ICECREAM, WINGS}

# TODO do or don't let the player buy power ups on level 1? and hide it add?
func _ready():
	get_tree().queue_delete($Selector)
	get_tree().queue_delete($HBoxContainer)
	Global.has_collar = true
	
	setup_prelevel_ui()
	
	# Start a timer or wait for player input to proceed to the next level
	$Timer.start()
	
	# Display the price counter for each powerup
	set_powerup_price_display(get_powerup_prices())
	
	# Show powerups if level 2+
	#if Global.level_count > 1:
		#$HBoxContainer.show()
	
	current_selection = powerup.NONE

# TODO ignore input when in game
func _input(event):
	if Input.is_action_just_pressed("ui_left"):
		if current_selection == 0:
			# Switch to burger
			#$Selector.show()
			#$Selector.global_position = Vector2(162,556)
			current_selection = powerup.BURGER
		elif current_selection == 1:
			# Switch to wings
			#$Selector.show()
			#$Selector.global_position = Vector2(1135,556)
			current_selection = powerup.WINGS
		elif current_selection == 2:
			# Switch to burger
			#$Selector.show()
			#$Selector.global_position = Vector2(162,556)
			current_selection = powerup.BURGER
		elif current_selection == 3:
			# Switch to icecream
			#$Selector.show()
			#$Selector.global_position = Vector2(637,556)
			current_selection = powerup.ICECREAM

	elif Input.is_action_just_pressed("ui_right"):
		if current_selection == 0:
			# Switch to burger
			#$Selector.show()
			#$Selector.global_position = Vector2(162,556)
			current_selection = powerup.BURGER
		elif current_selection == 1:
			# Switch to icecream
			#$Selector.show()
			#$Selector.global_position = Vector2(637,556)
			current_selection = powerup.ICECREAM
		elif current_selection == 2:
			# Switch to wings
			#$Selector.show()
			#$Selector.global_position = Vector2(1135,556)
			current_selection = powerup.WINGS
		elif current_selection == 3:
			# TODO should I remember the last selected position or nah?
			# Time is limited in this menu...
			# Switch back to burger
			#$Selector.show()
			#$Selector.global_position = Vector2(162,556)
			current_selection = powerup.BURGER
	elif Input.is_action_just_pressed("ui_cancel"):
		#$Selector.hide()
		current_selection = powerup.NONE
	elif Input.is_action_just_pressed("keyboard_0"):
		# Hide the selector
		#$Selector.hide()
		current_selection = powerup.NONE
	elif Input.is_action_just_pressed("keyboard_1"):
		# Switch to burger
		#$Selector.show()
		#$Selector.global_position = Vector2(162,556)
		current_selection = powerup.BURGER
	elif Input.is_action_just_pressed("keyboard_2"):
		# Switch to icecream
		#$Selector.show()
		#$Selector.global_position = Vector2(637,556)
		current_selection = powerup.ICECREAM
	elif Input.is_action_just_pressed("keyboard_3"):
		# Switch to wings
		#$Selector.show()
		#$Selector.global_position = Vector2(1135,556)
		current_selection = powerup.WINGS

func _on_timer_timeout():
	Global.start_next_level()
	
func setup_prelevel_ui():
	$ColorRect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
# Set the lives and level name labels
	$LevelName.text = Global.get_level_name(Global.level_count)
	$LevelName.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	$LevelName.offset_top += 44
	$LevelName.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	$x.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$x.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	$Lives.text = str(Global.total_lives)
	$Lives.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$Lives.offset_left = 125
	$Lives.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	$Dog.global_position = $x.get_global_transform().origin - Vector2(175, 48)
	
	$BoneX.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$BoneX.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$BoneX.offset_top += 150  # Push it below the previous row
	
	$BoneCount.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$BoneCount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$BoneCount.offset_left = 100
	$BoneCount.offset_top += 150
	$BoneCount.text = str(Global.total_bones)

	$Bone.global_position = $BoneX.get_global_transform().origin - Vector2(190, 0)


func get_powerup_prices():
	var hamburger: int = Global.hamburger_price
	var icecream: int = Global.icecream_price
	var wings: int = Global.wings_price
	var powerup_prices = [hamburger, icecream, wings]
	return powerup_prices

func set_powerup_price_display(prices: Array):
	pass
	#$HBoxContainer/Hamburger/HamburgerPrice.text = str(prices[0])
	#$HBoxContainer/Icecream/IcecreamPrice.text = str(prices[1])
	#$HBoxContainer/Wings/WingsPrice.text = str(prices[2])
