@tool
extends EditorImportPlugin

const T17_TILE_INDEX_MASK = 0x3ff
const T17_TILE_ATTR_SHIFT = 10

enum Presets { DEFAULT }

func _get_importer_name():
	return "team17.tilemap"

func _get_visible_name():
	return "Team 17 Tilemap"

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

func _get_import_options(path, preset_index):
	match preset_index:
		Presets.DEFAULT:
			return [
				{"name": "TileSize", "default_value": 16, "hint_string": "pixel size of tile"}
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
var iffP:String				# IFF paletter file
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
var tileMapBitmap:String	# bitmap file for tilemap from

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
	print_debug("Parsing Team 17 tilemap: ", source_file)
	var f = FileAccess.open(source_file, FileAccess.READ)
	if f == null:
		return FileAccess.get_open_error()
	f.big_endian = true # reading amiga format
	
	var hName = hunkName(f)
	if "T7MP" != hName:
		print_debug("Not Team17 map format")
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
				print_debug("Skipping unused...")
				f.seek(f.get_position() + hSize)
	f.close()
	print_debug("Parsing DONE Team 17 tilemap: ", source_file)

	return OK

func getTileSetBitmapName(source_file:String):
	var parts = iffP.rsplit(":", false, 1)	# remove volume
	if len(parts) != 2:
		return ERR_FILE_BAD_PATH
	if !parts[1].ends_with("-IFF"):	# check extension
		return ERR_FILE_BAD_PATH
	tileMapBitmap = source_file.get_base_dir() + "/" + parts[1].replace("-IFF", ".png")
	return OK

# loads tileset bitmap as texture atlas
func loadTileSetAtlasSource(path: String, tileSize:int):
	if not ResourceLoader.exists(path, "Image"):
		return null
	
	var tx: Texture2D = load(path)
	var w = tx.get_width()
	var h = tx.get_height()
	print_debug("Tileset texture atlas size:",w , ",", h, "px")
	var tilesX:int = w / tileSize
	var tilesY:int = h / tileSize
	print_debug("Tileset texture atlas tiles:", tilesX, ",", tilesY)

	var tas = TileSetAtlasSource.new()
	tas.margins = Vector2i(0,0)
	tas.separation = Vector2i(0,0)
	tas.use_texture_padding = false # NOTE: possible lines between tiles
	tas.texture_region_size = Vector2i(tileSize,tileSize)
	tas.texture = tx
	# init all tiles in atlas 
	for y in tilesY:
		for x in tilesX:
			tas.create_tile(Vector2i(x,y))
	return tas

func createTileSet(tas:TileSetAtlasSource, tileSize:int):
	var ts = TileSet.new()
	ts.tile_shape = TileSet.TILE_SHAPE_SQUARE
	ts.tile_size = Vector2i(tileSize,tileSize)
	ts.set_meta("IFFC", iffC)		# Add tile attributes
	ts.add_source(tas)
	var w = tas.texture_region_size.x
	var h = tas.texture_region_size.y
	#print_debug("Tileset texture atlas size:",w , ",", h)
	var tilesX:int = w / tileSize
	var tilesY:int = h / tileSize
	#print_debug("Tileset tiles:", tilesX, ",", tilesY)
	var tSize = Vector2(tileSize, tileSize)

	var tShape = RectangleShape2D.new()
	tShape.extents = Vector2(tileSize/2, tileSize/2)
	var tShapeOffset = Vector2(tileSize/2, tileSize/2)

	#var tID = 0
	#for y in tilesY:
	#	for x in tilesX:
	#		ts.create_tile(tID)
	#		ts.tile_set_texture(tID, tx)
	#		var tPos = Vector2(x * tileSize, y * tileSize)
	#		var region = Rect2(tPos, tSize)
	#		ts.tile_set_region(tID, region)

	#		var tileDefAttr = iffC[tID]
	#		# just check if there is some value
	#		if (tileDefAttr & T17_TILE_INDEX_MASK) != 0:
	#			print_debug("Tile:", tID, " AttrValue:", tileDefAttr & T17_TILE_INDEX_MASK)
	#		# get attribute
	#		tileDefAttr = tileDefAttr >> T17_TILE_ATTR_SHIFT
	#		match tileDefAttr:
	#			0:
	#				pass
	#			6:
	#				ts.tile_set_shape(tID, 6, tShape)
	#				ts.tile_set_shape_offset(tID, 6, tShapeOffset)
	#			55: # This tile can be picked up
	#				ts.tile_set_shape(tID, 55, tShape)
	#				ts.tile_set_shape_offset(tID, 55, tShapeOffset)
	#			61:	# Impassible
	#				ts.tile_set_shape(tID, 61, tShape)
	#				ts.tile_set_shape_offset(tID, 61, tShapeOffset)
	#			63: # These tiles can be walked upon
	#				ts.tile_set_shape(tID, 63, tShape)
	#				ts.tile_set_shape_offset(tID, 63, tShapeOffset)
	#			_:
	#				print_debug("TileID:", tID ," Unhandled default attr:", tileDefAttr)
	#		tID += 1
	return ts


func createTileMap(name, tileSize, ts:TileSet):
	var tm = TileMap.new()
	tm.set_name(name)
	tm.tile_set = ts
	print_debug("TileMap:", name, " Layers:", tm.get_layers_count())
	
	var tiles = Xblk * Yblk
	for i in tiles:
		var cell_x = i % Xblk
		var cell_y = int(i / Xblk)
		var tileIndex = body[i] & T17_TILE_INDEX_MASK
		var tileMapAttr = body[i] >> T17_TILE_ATTR_SHIFT
		var tileDefAttr = iffC[tileIndex]
		#if tileMapAttr != 0 && tileMapAttr != (tileDefAttr >> T17_TILE_ATTR_SHIFT):
		#	print_debug("Tile:", tileIndex, " MapAttr:", tileMapAttr, " DefAttr:", tileDefAttr >> T17_TILE_ATTR_SHIFT)
		var cellCords = Vector2i(cell_x*tileSize, cell_y*tileSize)
		var atlasCords = Vector2i(0,0) # TODO: read cord
		tm.set_cell(0, cellCords, -1, atlasCords, 0)
	return tm

func _import(source_file, save_path, options, platform_variants, gen_files):
	var name = source_file.get_file().get_basename()
	# root node for scene
	var root = Node2D.new()
	root.set_name(name)

	# tilemap parse data
	var err = parseTileMap(source_file)
	if err != OK:
		return err

	# create atlas source texture
	err = getTileSetBitmapName(source_file)
	if err != OK:
		return err
	
	var tas = loadTileSetAtlasSource(tileMapBitmap, options["TileSize"])
	if null == tas:
		printerr("File:", tileMapBitmap, ERR_FILE_NOT_FOUND)
		return ERR_FILE_NOT_FOUND

	# create tileset
	var ts = createTileSet(tas, options["TileSize"])
	
	# tilemap
	var tm = createTileMap(name + "_tilemap", options["TileSize"], ts)
	root.add_child(tm)
	#tm.set_owner(root)
	
	# create scene for save
	var scene = PackedScene.new()
	err = scene.pack(root)
	if err != OK:
		return err

	return ResourceSaver.save(scene, "%s.%s" % [save_path, _get_save_extension()])
	
