extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const WALK_DURATION = 2.0

var direction = 1  # 1 for right, -1 for left

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Node variables
@onready var player_sprite = $AnimatedSprite2D
@onready var walk_timer = $WalkTimer
@onready var turn_timer = $TurnTimer

func _ready():
	player_sprite.speed_scale = 0.7
	player_sprite.play("idle_collar")

func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta
	move_and_slide()
	
func _on_walk_timer_timeout():
	pass # Replace with function body.

func _on_turn_timer_timeout():
	pass # Replace with function body.

# Reactions from NPCs
func hurt():
	$Hurt.play()
