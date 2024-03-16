@tool
extends EditorPlugin

var tilemap_import = null

func get_name():
	return "Team 17 importer"

func _enter_tree():
	tilemap_import = preload("tilemap.gd").new()
	add_import_plugin(tilemap_import)

func _exit_tree():
	remove_import_plugin(tilemap_import)
	tilemap_import = null
