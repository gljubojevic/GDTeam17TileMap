extends CharacterBody2D

@export var GRAVITY = 200.0
@export var WALK_SPEED = 150
@export var JUMP_SPEED = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	#set_up_direction(Vector2(0, -1))
	set_floor_stop_on_slope_enabled(false)
	set_floor_constant_speed_enabled(false)
	set_floor_max_angle(deg_to_rad(80))
	set_floor_snap_length(5)
	# setup camera
	var tm:TileMap = get_parent()
	limitCameraToTileMap(tm, $Camera2D)

func limitCameraToTileMap(tm:TileMap, c:Camera2D):
	print_debug("Limiting camera to TileMap: ",tm.name)
	var ts:TileSet = tm.get_tileset();
	var tileSize:Vector2i = ts.get_tile_size()
	var tmSize = tm.get_used_rect()
	c.set_limit(SIDE_LEFT, tmSize.position.x * tileSize.x)
	c.set_limit(SIDE_TOP, tmSize.position.y * tileSize.y)
	c.set_limit(SIDE_RIGHT, tmSize.size.x * tileSize.x)
	c.set_limit(SIDE_BOTTOM, tmSize.size.y * tileSize.y)

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
