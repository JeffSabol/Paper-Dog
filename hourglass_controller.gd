extends Node2D

@export var hourglass_sprites: Array[AnimatedSprite2D]
@export var total_frames := 1024
@export var frames_per_sprite := 128
@export var fps := 6.0

var current_frame := 0.0
var current_index := 0

func _ready():
	for sprite in hourglass_sprites:
		sprite.stop()
		sprite.visible = false

	hourglass_sprites[0].visible = true
	hourglass_sprites[0].play()

func _process(delta):
	current_frame += fps * delta
	if current_frame >= total_frames:
		current_frame = 0
	
	var new_index = int(current_frame / frames_per_sprite)
	new_index = min(new_index, hourglass_sprites.size() - 1)

	if new_index != current_index:
		hourglass_sprites[current_index].stop()
		hourglass_sprites[current_index].visible = false

		current_index = new_index
		hourglass_sprites[current_index].visible = true
		hourglass_sprites[current_index].frame = 0
		hourglass_sprites[current_index].play()
