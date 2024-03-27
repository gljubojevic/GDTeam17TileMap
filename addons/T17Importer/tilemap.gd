@tool
extends EditorImportPlugin

const T17_TILE_INDEX_MASK = 0x3ff
const T17_TILE_ATTR_SHIFT = 10
const T17_DEFAULT_ATTR_LAYER_NAME = "DefaultAttributes"

enum Presets { DEFAULT }

# SuperFrog tile attributes in TileMap and as default for tiles
enum SuperFrogTileAttr {
	Nothing, 			# 00 Nothing
	Enemy01,			# 01 Enemy 1 or Witch boss
	Enemy02,			# 02 Enemy 2
	Enemy03,			# 03 Enemy 3
	JumpPad1,			# 04 Jumppad type 1
	JumpPad2,			# 05 Jumppad type 2 (other background)
	Lethal,				# 06 Lethal (spikes, fire, etc.)
	JumpPadSideways,	# 07 Jumppad sideways
	Coin,				# 08 Coin
	SecretCoin,			# 09 "Secret" coin
	Enemy04,			# 10 Enemy 4
	Enemy05,			# 11 Enemy 5
	Enemy06,			# 12 Enemy 6
	Enemy07,			# 13 Enemy 7
	Enemy08,			# 14 Enemy 8
	Enemy09,			# 15 Enemy 9
	Enemy10,			# 16 Enemy 10
	Enemy11,			# 17 Enemy 11
	Enemy12,			# 18 Enemy 12
	Enemy13,			# 19 Enemy 13
	Enemy14,			# 20 Enemy 14
	Enemy15,			# 21 Enemy 15
	Enemy16,			# 22 Enemy 16
	Enemy17,			# 23 Enemy 17
	Enemy18,			# 24 Enemy 18
	Enemy19,			# 25 Enemy 19
	Enemy20,			# 26 Enemy 20
	Enemy21,			# 27 Enemy 21
	Enemy22,			# 28 Enemy 22
	LevelExitMark,		# 29 Level exit X image
	Unused30,			# 30 Not used
	Unused31,			# 31 Not used
	Unknown32,			# 32 Unknown, used once in w2l3, leftover?
	Unused33,			# 33 Not used
	Unused34,			# 34 Not used
	Unused35,			# 35 Not used
	Retracting,			# 36 Retracting platform (not in world 4)
	StopEnemies,		# 37 Stop walking enemies
	SecretPassage,		# 38 Secret passage
	SuckingEntrance,	# 39 Big sucking thing entrance
	SuckingSuctionV,	# 40 Big sucking thing suction vertical
	SuckingSuctionVStp,	# 41 Big sucking thing stop (vertical)
	SuckingSuctionH,	# 42 Big sucking thing suction horizontal
	SuckingSuctionHStp,	# 43 Big sucking thing stop (horizontal)
	ThrusterPad,		# 44 Thruster pad
	CoinDispenser,		# 45 Coin dispenser (jump to get coins)
	WetPushLeft,		# 46 Wet push left
	WetPushRight,		# 47 Wet push right
	SwitchDoor1,		# 48 Switch\door combo 1
	SwitchDoor2,		# 49 Switch\door combo 2
	SwitchDoor3,		# 50 Switch\door combo 3
	SwitchDoor4,		# 51 Switch\door combo 4
	SwitchDoor5,		# 52 Switch\door combo 5?
	PlayerStart,		# 53 Player start
	LevelExit,			# 54 Level exit
	Pickup,				# 55 This tile can be picked up
	Slippery,			# 56 Slimy\wet\icy
	Water,				# 57 Water (swimmable)
	Unused58,			# 58 Not used
	Unused59,			# 59 Not used
	Unused60,			# 60 Not used
	Impassible,			# 61 Impassible
	PassFromBelow,		# 62 Player can pass these tiles from below
	WalkOn				# 63 These tiles can be walked upon
}

func _get_importer_name():
	return "team17.tilemap"

func _get_visible_name():
	return "Team 17 TileMap"

func _get_recognized_extensions():
	return ["t7mp"]

func _get_save_extension():
	return "tscn"

func _get_resource_type():
	return "PackedScene"

func _get_preset_count():
	return Presets.size()

func _get_option_visibility(path, option_name, options):
	return true

func _get_preset_name(preset_index):
	match preset_index:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

func _get_priority():
	return 1.0

func _get_import_options(path, preset_index):
	match preset_index:
		Presets.DEFAULT:
			return [
				{
					"name": "TileSize",
					"default_value": 16
				},
				{
					"name": "TileSetTexture",
					"default_value": "Default",
					"property_hint": PROPERTY_HINT_FILE,
					"hint_string": "*.png;Resource File"
				},
				{
					"name": "TileSetCollision",
					"default_value": "Default",
					"property_hint": PROPERTY_HINT_FILE,
					"hint_string": "*.png;Resource File"
				},
				{
					"name": "CollisionBitmapEpsilon",
					"default_value": 0.9,
					"property_hint": PROPERTY_HINT_RANGE,
					"hint_string": "0,3"
				}
			]
		_:
			return[]

func _get_import_order():
	return ResourceImporter.IMPORT_ORDER_SCENE

func hunkName(f:FileAccess):
	var b = f.get_buffer(4)
	return b.get_string_from_ascii()	

func hunkSize(f:FileAccess):
	return f.get_32()

var Xblk:int				# tilemap size X in tiles
var Yblk:int				# tilemap size Y in tiles
var iffP:String				# IFF palette file
var palAFile:String			# Palette A filename
var palAColors:Array		# Palette A colors
var palBFile:String			# Palette B filename
var palBColors:Array		# Palette B colors
var palCFile:String			# Palette C filename
var palCColors:Array		# Palette C colors
var palDFile:String			# Palette D filename
var palDColors:Array		# Palette D colors
var body:Array 				# tilemap tiles body
var iffC:Array				# tileset attributes
var cccL:Array				# ?

func readUInt16Array(b:PackedByteArray):
	var dta:Array
	var i:int = 0
	while i < b.size():
		var v:int = 0	# reading 16 bits as unsigned int
		v |= b[i] << 8
		v |= b[i+1]
		dta.append(v)
		i+=2
	return dta

func print_DebugArray(ar:Array):
	var fmt = "%04d -> 0x%08X -> %08d"
	for i in range(len(ar)):
		print_debug(fmt % [i, ar[i], ar[i]])

func getPaletteFileName(b:PackedByteArray, pal:String):
	var fn = b.slice(0, 64)
	var name = fn.get_string_from_ascii()
	print_debug("%s file: %s" % [pal, name])
	return name

func getPaletteColors(b:PackedByteArray, pal:String):
	var p = b.slice(64, b.size())
	var col = readUInt16Array(p)
	print_DebugArray(col)
	return col

func parseTileMap(source_file:String):
	print_debug("Parsing Team 17 TileMap: ", source_file)
	var f = FileAccess.open(source_file, FileAccess.READ)
	if f == null:
		return FileAccess.get_open_error()
	f.big_endian = true # reading Amiga format (big endian)
	
	var hName = hunkName(f)
	if "T7MP" != hName:
		print_debug("Not Team17 TileMap format")
		f.close()
		return ERR_PARSE_ERROR
	var hSize = hunkSize(f)
	var fSize = f.get_32()
	print_debug(hName,":", hSize, " file size:", fSize)

	while f.get_position() < fSize:
		hName = hunkName(f)
		hSize = hunkSize(f)
		print_debug(hName,":", hSize)
		match hName:
			"XBLK":
				Xblk = f.get_32()
				print_debug("XBLK:", Xblk)
			"YBLK":
				Yblk = f.get_32()
				print_debug("YBLK:", Yblk)
			"IFFP":
				var b = f.get_buffer(hSize)
				iffP = b.get_string_from_ascii()
				print_debug("IFFP:", iffP, " len:", len(iffP))
			"PALA":
				var b = f.get_buffer(hSize)
				palAFile = getPaletteFileName(b, hName)
				palAColors = getPaletteColors(b, hName)
			"PALB":
				var b = f.get_buffer(hSize)
				palBFile = getPaletteFileName(b, hName)
				palBColors = getPaletteColors(b, hName)
			"PALC":
				var b = f.get_buffer(hSize)
				palCFile = getPaletteFileName(b, hName)
				palCColors = getPaletteColors(b, hName)
			"PALD":
				var b = f.get_buffer(hSize)
				palDFile = getPaletteFileName(b, hName)
				palDColors = getPaletteColors(b, hName)
			"CCCL":
				var b = f.get_buffer(hSize)
				cccL = readUInt16Array(b)
				print_DebugArray(cccL)
			"IFFC":
				var b = f.get_buffer(hSize)
				iffC = readUInt16Array(b)
				print_debug("IFFC tiles:", len(iffC))
			"BODY":
				var b = f.get_buffer(hSize)
				body = readUInt16Array(b)
			_:
				print_debug("Skipping %s unused..." % [hName])
				f.seek(f.get_position() + hSize)
	f.close()
	print_debug("Parsing Team 17 TileMap: ", source_file, " DONE!")
	return OK

func createTileSetAtlasSource(tx: Texture2D, tileSize:int):
	var tiles:Vector2i = tx.get_size()
	print_debug("TileSet texture atlas size:",tiles, "px")
	tiles = tiles / tileSize
	print_debug("TileSet texture atlas tiles:", tiles)

	var tas = TileSetAtlasSource.new()
	tas.margins = Vector2i(0,0)
	tas.separation = Vector2i(0,0)
	#tas.use_texture_padding = false # NOTE: possible lines between tiles
	tas.texture_region_size = Vector2i(tileSize,tileSize)
	tas.texture = tx
	# init all tiles in atlas 
	for y in tiles.y:
		for x in tiles.x:
			tas.create_tile(Vector2i(x,y))
	return tas

func addTileCollisionFromBitMap(tID:int, td:TileData, cbm:BitMap, cbmEpsilon:float, tileSize:int, tilePos:Vector2i):
	var tbm:BitMap = BitMap.new()
	tbm.create(Vector2i(tileSize, tileSize))
	var pos:Vector2i = tilePos * tileSize
	var bitCount:int = 0 # count active bits while creating tile bitmap
	for y in tileSize:
		for x in tileSize:
			if cbm.get_bit(pos.x + x,pos.y + y):
				tbm.set_bit(x,y,true)
				bitCount+=1
	# rectangle for creating tile collision polygons
	var tileRect = Rect2i(0,0,tileSize, tileSize)
	# default collision full rectangle
	var collision:Array = [
		PackedVector2Array(
			[Vector2i(0, 0), Vector2(tileSize, 0), Vector2(tileSize, tileSize), Vector2(0, tileSize)]
		)
	]
	# active bits in collision bitmap, create collision poygons
	if bitCount != 0:
		collision = tbm.opaque_to_polygons(tileRect, cbmEpsilon)
	var collisionTransform:Transform2D = Transform2D(0, Vector2i(tileSize/2, tileSize/2))
	# might be more than one collision polygon
	for idx in collision.size():
		td.add_collision_polygon(0)
		td.set_collision_polygon_points(0, idx, collision[idx] * collisionTransform)

func tileAttrSuperFrog(tID:int, attr:int, td:TileData, cbm:BitMap, cbmEpsilon:float, tileSize:int, tilePos:Vector2i):
	# custom data from map
	td.set_custom_data(T17_DEFAULT_ATTR_LAYER_NAME, attr)
	# decode attribute for collision
	match attr:
		SuperFrogTileAttr.Nothing:
			pass
		SuperFrogTileAttr.Enemy01:			# 01 Enemy 1 or Witch boss
			pass
		SuperFrogTileAttr.Enemy02:			# 02 Enemy 2
			pass
		SuperFrogTileAttr.Enemy03:			# 03 Enemy 3
			pass
		SuperFrogTileAttr.JumpPad1:			# 04 Jumppad type 1
			pass
		SuperFrogTileAttr.JumpPad2:			# 05 Jumppad type 2 (other background)
			pass
		SuperFrogTileAttr.Lethal:			# 06 Lethal (spikes, fire, etc.)
			pass
		SuperFrogTileAttr.Coin:				# 08 Coin
			pass
		SuperFrogTileAttr.SecretCoin:		# 09 "Secret" coin
			pass
		SuperFrogTileAttr.Enemy04:			# 10 Enemy 4
			pass
		SuperFrogTileAttr.Enemy05:			# 11 Enemy 5
			pass
		SuperFrogTileAttr.Enemy06:			# 12 Enemy 6
			pass
		SuperFrogTileAttr.Enemy07:			# 13 Enemy 7
			pass
		SuperFrogTileAttr.Enemy09:			# 15 Enemy 9
			pass
		SuperFrogTileAttr.Enemy10:			# 16 Enemy 10
			pass
		SuperFrogTileAttr.Enemy11:			# 17 Enemy 11
			pass
		SuperFrogTileAttr.Enemy12:			# 18 Enemy 12
			pass
		SuperFrogTileAttr.LevelExitMark:	# 29 Level exit X image
			pass
		SuperFrogTileAttr.StopEnemies:		# 37 Stop walking enemies
			pass
		SuperFrogTileAttr.CoinDispenser:	# 45 Coin dispenser (jump to get coins)
			addTileCollisionFromBitMap(tID, td, cbm, cbmEpsilon, tileSize, tilePos)
		SuperFrogTileAttr.SecretPassage:	# 38 Secret passage
			addTileCollisionFromBitMap(tID, td, cbm, cbmEpsilon, tileSize, tilePos)
		SuperFrogTileAttr.PlayerStart:		# 53 Player start
			pass
		SuperFrogTileAttr.LevelExit:		# 54 Level exit
			pass
		SuperFrogTileAttr.Pickup:			# 55 This tile can be picked up
			pass
		SuperFrogTileAttr.Impassible:		# 61 Impassible
			addTileCollisionFromBitMap(tID, td, cbm, cbmEpsilon, tileSize, tilePos)
		SuperFrogTileAttr.PassFromBelow:	# 62 Player can pass these tiles from below
			addTileCollisionFromBitMap(tID, td, cbm, cbmEpsilon, tileSize, tilePos)
		SuperFrogTileAttr.WalkOn:			# 63 These tiles can be walked upon
			addTileCollisionFromBitMap(tID, td, cbm, cbmEpsilon, tileSize, tilePos)
		_:
			print_debug("TileID:", tID ," Unhandeled attribute:", attr)

func createTileSet(tas:TileSetAtlasSource, cbm:BitMap, cbmEpsilon:float, tileSize:int):
	var ts = TileSet.new()
	ts.tile_shape = TileSet.TILE_SHAPE_SQUARE
	ts.tile_size = Vector2i(tileSize,tileSize)
	ts.add_source(tas)
	ts.add_custom_data_layer()	# for default tile attributes
	ts.set_custom_data_layer_name(0, T17_DEFAULT_ATTR_LAYER_NAME)
	ts.set_custom_data_layer_type(0, TYPE_INT)
	ts.add_physics_layer()		# for collision poygons

	var tID = 0
	var tasGrid:Vector2i = tas.get_atlas_grid_size()
	for y in tasGrid.y:
		for x in tasGrid.x:
			var attr = iffC[tID]
			# should not be value at index position
			if (attr & T17_TILE_INDEX_MASK) != 0:
				printerr("Tile:", tID, " has value:", attr, " at index bits")
			attr = attr >> T17_TILE_ATTR_SHIFT
			# tile to add layer data
			var pos:Vector2i = Vector2i(x,y)
			var td:TileData = tas.get_tile_data(pos,0)
			# TODO: add game selection SuperFrog, AlienBreed...
			tileAttrSuperFrog(tID, attr, td, cbm, cbmEpsilon, tileSize, pos)
			tID += 1
	return ts

func addAltTile(tID:int, attr:int, tas:TileSetAtlasSource, atlasCords:Vector2i, cbm:BitMap, cbmEpsilon:float, tileSize:int):
	var altID = tas.create_alternative_tile(atlasCords)
	var td:TileData = tas.get_tile_data(atlasCords, altID)
	# TODO: add game selection SuperFrog, AlienBreed...
	tileAttrSuperFrog(tID, attr, td, cbm, cbmEpsilon, tileSize, atlasCords)
	return altID

func createTileMap(name:String, tileSize:int, ts:TileSet, cbm:BitMap, cbmEpsilon:float):
	var tm = TileMap.new()
	tm.set_name(name)
	tm.tile_set = ts
	# atlas info to calc cords in atlas
	var tsSrcID = ts.get_source_id(0)
	var tas:TileSetAtlasSource = ts.get_source(tsSrcID)
	var atlasSize:Vector2i = tas.get_atlas_grid_size()
	# make reference dictionary for alternate tiles
	var altTiles:Dictionary = Dictionary();
	
	for i in body.size():
		var tID:int = body[i] & T17_TILE_INDEX_MASK
		var mapAttr:int = body[i] >> T17_TILE_ATTR_SHIFT
		var defAttr:int = iffC[tID] >> T17_TILE_ATTR_SHIFT
		var atlasCords = Vector2i(tID % atlasSize.x, tID / atlasSize.x)
		var altID:int = 0
		# check different attribute in TileMap from default in TileSet, for alternative tiles
		if mapAttr != defAttr:
			#print_debug("Different attribute tile:", tID, " TileMap:", mapAttr, " TileSet:", defAttr)
			if altTiles.has(tID):
				var altAttr:Dictionary = altTiles.get(tID)
				if altAttr.has(mapAttr):
					altID = altAttr[mapAttr]
				else:
					altID = addAltTile(tID, mapAttr, tas, atlasCords, cbm, cbmEpsilon, tileSize)
					altAttr[mapAttr] = altID
			else:
				altID = addAltTile(tID, mapAttr, tas, atlasCords, cbm, cbmEpsilon, tileSize)
				altTiles[tID] = {
					mapAttr: altID
				}
		# finaly set tilemap cell 
		var cords = Vector2i(i % Xblk, i / Xblk)
		tm.set_cell(0, cords, tsSrcID, atlasCords, altID)
	return tm

func assetFileName(tileMapFileName:String, assetFileName:String, defaultName:String, defaultFileExt:String):
	if assetFileName != "Default":
		return assetFileName
	return "%s/%s%s.%s" % [tileMapFileName.get_base_dir(), tileMapFileName.get_file().get_basename().substr(0,2), defaultName, defaultFileExt]

func loadTileSetTexture(tileMapFileName:String, tileSetFileName:String):
	tileSetFileName = assetFileName(tileMapFileName, tileSetFileName, "BM", "png")
	print_debug("Loading TileSet Texture2D: ", tileSetFileName)
	if not ResourceLoader.exists(tileSetFileName, "Image"):
		printerr("TileSet Texture2D: ", tileSetFileName, ERR_FILE_NOT_FOUND)
		return null
	var tx: Texture2D = load(tileSetFileName)
	return tx

func loadTileSetCollisionBitmap(tileMapFileName:String, tileSetCollisionFileName:String):
	tileSetCollisionFileName = assetFileName(tileMapFileName, tileSetCollisionFileName, "MS", "png")
	print_debug("Loading TileSet collision BitMap: ", tileSetCollisionFileName)
	if not ResourceLoader.exists(tileSetCollisionFileName, "BitMap"):
		printerr("TileSet collision BitMap: ", tileSetCollisionFileName, ERR_FILE_NOT_FOUND)
		return null
	var bm: BitMap = load(tileSetCollisionFileName)
	return bm

func _import(source_file, save_path, options, platform_variants, gen_files):
	var tileSize:int = options["TileSize"]
	var tileSetTextureFile:String = options["TileSetTexture"]
	var tileSetCollisionFile:String = options["TileSetCollision"]
	var collisionBitmapEpsilon:float = options["CollisionBitmapEpsilon"]
	print_debug("Importing Team17 TileMap:", source_file, " TileSize:", tileSize, " Texture:", tileSetTextureFile, " Collision:", tileSetCollisionFile)

	# base name of tilemap
	var name = source_file.get_file().get_basename()

	var tx:Texture2D = loadTileSetTexture(source_file, tileSetTextureFile)
	if tx == null:
		return ERR_FILE_NOT_FOUND

	var cbm:BitMap = loadTileSetCollisionBitmap(source_file, tileSetCollisionFile)
	if cbm == null:
		return ERR_FILE_NOT_FOUND
	
	var err = parseTileMap(source_file)
	if err != OK:
		printerr(err)
		return err
	
	var tas = createTileSetAtlasSource(tx, tileSize)
	var ts = createTileSet(tas, cbm, collisionBitmapEpsilon, tileSize)
	var tm = createTileMap(name + "_TileMap", tileSize, ts, cbm, collisionBitmapEpsilon)

	# root node for scene
	var root = Node2D.new()
	root.set_name(name)
	root.add_child(tm)
	tm.set_owner(root)
	
	# create scene for save
	var scene = PackedScene.new()
	err = scene.pack(root)
	if err != OK:
		printerr(err)
		return err

	return ResourceSaver.save(scene, "%s.%s" % [save_path, _get_save_extension()])
	
