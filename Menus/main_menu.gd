extends Node2D
# Main menu scripting

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if Paper Dog is running within the winter season
	if is_within_winter_dates():
		$TileMap.hide()
		$Snowmap.show()
		$SnowFlakes.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func is_within_winter_dates() -> bool:
	var current_datetime = Time.get_datetime_dict_from_system()
	var current_month = current_datetime.month
	var current_day = current_datetime.day

	# Check if the date is between December 22nd and December 31st
	if current_month == 12 and current_day >= 22:
		return true

	# Check if the date is between January 1st and March 21st
	if current_month == 1 or current_month == 2 or (current_month == 3 and current_day <= 21):
		return true

	return false


func _on_click_zone_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Global.goto_scene("res://DrowsyDoze/scenes/Main.tscn")
