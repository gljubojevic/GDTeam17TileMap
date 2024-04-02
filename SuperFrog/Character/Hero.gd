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
	# TileMap details
	var tm:TileMap = get_parent()
	var tmSize:Rect2i = tm.get_used_rect()
	var tileSize:Vector2i = getTileSize(tm)
	# setup player and camera
	limitCameraToTileMap(tmSize, tileSize, $Camera2D)
	positionPlayer(tm, tmSize, tileSize)

func getTileSize(tm:TileMap):
	var ts:TileSet = tm.get_tileset();
	return ts.get_tile_size()

func limitCameraToTileMap(tmSize:Rect2i, tileSize:Vector2i, c:Camera2D):
	c.set_limit(SIDE_LEFT, tmSize.position.x * tileSize.x)
	c.set_limit(SIDE_TOP, tmSize.position.y * tileSize.y)
	c.set_limit(SIDE_RIGHT, tmSize.size.x * tileSize.x)
	c.set_limit(SIDE_BOTTOM, tmSize.size.y * tileSize.y)

func positionPlayer(tm:TileMap, tmSize:Rect2i, tileSize:Vector2i):
	var start = Vector2i(0,0)
	for y in tmSize.size.y:
		for x in tmSize.size.x:
			var td = tm.get_cell_tile_data(0, Vector2i(x,y))
			var attr:int = td.get_custom_data("DefaultAttributes")
			if attr == 53:
				start = Vector2i(x,y)
	position = start * tileSize
	print_debug("Player start:", position)

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
