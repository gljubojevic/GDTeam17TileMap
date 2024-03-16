@tool
extends EditorImportPlugin

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

func hunkName(f:File):
	var b = f.get_buffer(4)
	return b.get_string_from_ascii()	

func hunkSize(f:File):
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

func readInt16Array(b:PackedByteArray):
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
	var fn = b.slice(0, 63)
	var name = fn.get_string_from_ascii()
	print_debug("%s file: %s" % [pal, name])
	return name

func getPaletteColors(b:PackedByteArray, pal:String):
	var p = b.slice(64, b.size()-1)
	var col = readInt16Array(p)
	print_DebugArray(col)
	return col

func parseTileMap(source_file):
	print_debug("Loading Team 17 tilemap: ", source_file)
	var f = File.new()
	var err = f.open(source_file, File.READ)
	if err != OK:
		return err
	f.endian_swap = true # reading amiga format
	
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
				cccL = readInt16Array(b)
				print_DebugArray(cccL)
			"IFFC":
				var b = f.get_buffer(hSize)
				iffC = readInt16Array(b)
				print_debug("IFFC tiles:", len(iffC))
			"BODY":
				var b = f.get_buffer(hSize)
				body = readInt16Array(b)
			_:
				print_debug("Skipping unused...")
				f.seek(f.get_position() + hSize)
	f.close()
	print_debug("Loading DONE Team 17 tilemap: ", source_file)

	return OK

func getTileSetBitmapName(source_file):
	# remove volume
	var parts = iffP.rsplit(":", false, 1)
	if len(parts) != 2:
		return ERR_FILE_BAD_PATH
	# check extension
	if !parts[1].ends_with("-IFF"):
		return ERR_FILE_BAD_PATH
	tileMapBitmap = source_file.get_base_dir() + "/" + parts[1].replace("-IFF", ".png")
	return OK

# loads tileset bitmap as texture
func loadTileSetTexture(path):
	var img = Image.new()
	var err = img.load(path)
	if err != OK:
		printerr(err)
		return null
	var tx = ImageTexture.new()
	tx.storage = ImageTexture.STORAGE_RAW
	tx.create_from_image(img)
	tx.flags = 0	# must be no flags to get crisp image
	return tx

func createTileSet(tx:ImageTexture, tileSize:int):
	var ts = TileSet.new()
	ts.set_meta("IFFC", iffC)		# Add tile attributes
	var w = tx.get_width()
	var h = tx.get_height()
	print_debug("Tileset texture size:",w , ",", h)
	var tilesX:int = w / tileSize
	var tilesY:int = h / tileSize
	print_debug("Tileset tiles:", tilesX, ",", tilesY)
	var tSize = Vector2(tileSize, tileSize)

	var tShape = RectangleShape2D.new()
	tShape.extents = Vector2(tileSize/2, tileSize/2)
	var tShapeOffset = Vector2(tileSize/2, tileSize/2)

	var tID = 0
	for y in tilesY:
		for x in tilesX:
			ts.create_tile(tID)
			ts.tile_set_texture(tID, tx)
			var tPos = Vector2(x * tileSize, y * tileSize)
			var region = Rect2(tPos, tSize)
			ts.tile_set_region(tID, region)

			var tileDefAttr = iffC[tID]
			# just check if there is some value
			if (tileDefAttr & 0x3ff) != 0:
				print_debug("Tile:", tID, " AttrValue:", tileDefAttr & 0x3ff)
			# get attribute
			tileDefAttr = tileDefAttr >> 10
			match tileDefAttr:
				0:
					pass
				6:
					ts.tile_set_shape(tID, 6, tShape)
					ts.tile_set_shape_offset(tID, 6, tShapeOffset)
				55: # This tile can be picked up
					ts.tile_set_shape(tID, 55, tShape)
					ts.tile_set_shape_offset(tID, 55, tShapeOffset)
				61:	# Impassible
					ts.tile_set_shape(tID, 61, tShape)
					ts.tile_set_shape_offset(tID, 61, tShapeOffset)
				63: # These tiles can be walked upon
					ts.tile_set_shape(tID, 63, tShape)
					ts.tile_set_shape_offset(tID, 63, tShapeOffset)
				_:
					print_debug("TileID:", tID ," Unhandled default attr:", tileDefAttr)

			tID += 1
	return ts

func createTileMap(name, tileSize, ts:TileSet):
	var tm = TileMap.new()
	tm.set_name(name)
	tm.cell_y_sort = true
	tm.mode = TileMap.MODE_SQUARE
	tm.cell_tile_origin = TileMap.TILE_ORIGIN_TOP_LEFT
	tm.cell_half_offset = TileMap.HALF_OFFSET_DISABLED
	tm.cell_size = Vector2(tileSize,tileSize)
	tm.tile_set = ts

	var tiles = Xblk * Yblk
	for i in tiles:
		var cell_x = i % Xblk
		var cell_y = int(i / Xblk)
		var tileIndex = body[i] & 0x3ff
		#var tileMapAttr = body[i] >> 10
		#var tileDefAttr = iffC[tileIndex]
		#if tileMapAttr != 0 && tileMapAttr != (tileDefAttr >> 10):
		#	print_debug("Tile:", tileIndex, " MapAttr:", tileMapAttr, " DefAttr:", tileDefAttr >> 10)
		tm.set_cell(cell_x, cell_y, tileIndex)
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

	# create tileset
	err = getTileSetBitmapName(source_file)
	if err != OK:
		return err
	
	var tx = loadTileSetTexture(tileMapBitmap)
	if null == tx:
		return ERR_FILE_NOT_FOUND
	var ts = createTileSet(tx, options["TileSize"])
	
	# tilemap
	var tm = createTileMap(name + "_tilemap", options["TileSize"], ts)
	root.add_child(tm)
	tm.set_owner(root)
	
	# create scene for save
	var scene = PackedScene.new()
	err = scene.pack(root)
	if err != OK:
		return err

	return ResourceSaver.save("%s.%s" % [save_path, _get_save_extension()], scene)
