# Jeff Sabol
# Controls the UI for the pre-level screen. Mainly for selecting the powerups.
extends Control

var current_selection
enum powerup {NONE, BURGER, ICECREAM, WINGS}

# TODO do or don't let the player buy power ups on level 1? and hide it add?
func _ready():
	# Set the lives and level name labels
	$Lives.text = str(Global.total_lives)
	$LevelName.text = Global.get_level_name(Global.level_count)
	
	# Start a timer or wait for player input to proceed to the next level
	$Timer.start()
	
	# Display the price counter for each powerup
	set_powerup_price_display(get_powerup_prices())
	
	# Show powerups if level 2+
	if Global.level_count > 1:
		$HBoxContainer.show()
		
	$BoneCount.text = str(Global.total_bones)
	
	current_selection = powerup.NONE

# TODO ignore input when in game
func _input(event):
	if Input.is_action_just_pressed("ui_left"):
		if current_selection == 0:
			# Switch to burger
			$Selector.show()
			$Selector.global_position = Vector2(162,556)
			current_selection = powerup.BURGER
		elif current_selection == 1:
			# Switch to wings
			$Selector.show()
			$Selector.global_position = Vector2(1135,556)
			current_selection = powerup.WINGS
		elif current_selection == 2:
			# Switch to burger
			$Selector.show()
			$Selector.global_position = Vector2(162,556)
			current_selection = powerup.BURGER
		elif current_selection == 3:
			# Switch to icecream
			$Selector.show()
			$Selector.global_position = Vector2(637,556)
			current_selection = powerup.ICECREAM

	elif Input.is_action_just_pressed("ui_right"):
		if current_selection == 0:
			# Switch to burger
			$Selector.show()
			$Selector.global_position = Vector2(162,556)
			current_selection = powerup.BURGER
		elif current_selection == 1:
			# Switch to icecream
			$Selector.show()
			$Selector.global_position = Vector2(637,556)
			current_selection = powerup.ICECREAM
		elif current_selection == 2:
			# Switch to wings
			$Selector.show()
			$Selector.global_position = Vector2(1135,556)
			current_selection = powerup.WINGS
		elif current_selection == 3:
			# TODO should I remember the last selected position or nah?
			# Time is limited in this menu...
			# Switch back to burger
			$Selector.show()
			$Selector.global_position = Vector2(162,556)
			current_selection = powerup.BURGER
	elif Input.is_action_just_pressed("ui_cancel"):
		$Selector.hide()
		current_selection = powerup.NONE
	elif Input.is_action_just_pressed("keyboard_0"):
		# Hide the selector
		$Selector.hide()
		current_selection = powerup.NONE
	elif Input.is_action_just_pressed("keyboard_1"):
		# Switch to burger
		$Selector.show()
		$Selector.global_position = Vector2(162,556)
		current_selection = powerup.BURGER
	elif Input.is_action_just_pressed("keyboard_2"):
		# Switch to icecream
		$Selector.show()
		$Selector.global_position = Vector2(637,556)
		current_selection = powerup.ICECREAM
	elif Input.is_action_just_pressed("keyboard_3"):
		# Switch to wings
		$Selector.show()
		$Selector.global_position = Vector2(1135,556)
		current_selection = powerup.WINGS

func _on_timer_timeout():
	Global.start_next_level()

func get_powerup_prices():
	var hamburger: int = Global.hamburger_price
	var icecream: int = Global.icecream_price
	var wings: int = Global.wings_price
	var powerup_prices = [hamburger, icecream, wings]
	return powerup_prices

func set_powerup_price_display(prices: Array):
	$HBoxContainer/Hamburger/HamburgerPrice.text = str(prices[0])
	$HBoxContainer/Icecream/IcecreamPrice.text = str(prices[1])
	$HBoxContainer/Wings/WingsPrice.text = str(prices[2])
