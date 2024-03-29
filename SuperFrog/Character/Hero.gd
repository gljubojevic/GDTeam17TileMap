extends CharacterBody2D

@export var GRAVITY = 200.0
@export var WALK_SPEED = 150
@export var JUMP_SPEED = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	#set_up_direction(Vector2(0, -1))
	set_floor_stop_on_slope_enabled(false)
	set_floor_constant_speed_enabled(true)
	#set_floor_snap_length(1)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	# handle left/right
	if Input.is_action_pressed("ui_left"):
		velocity.x = -WALK_SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  WALK_SPEED
	else:
		velocity.x = 0

	# handle falling down
	velocity.y += delta * GRAVITY
	# handle jumping
	if is_on_floor() and Input.is_action_pressed("ui_up"):
		velocity.y += -JUMP_SPEED
	
	# We don't need to multiply velocity by delta because "move_and_slide" already takes delta time into account.
	set_velocity(velocity)
	move_and_slide()
