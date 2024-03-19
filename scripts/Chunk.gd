class_name Chunk
extends Node

var coords: Vector2
var tiles = {}
var tile_walkable = {}

#@onready var label = $"PanelContainer/Label"

func set_coords(chunk_coords: Vector2):
	coords = chunk_coords
#	label.text = str(chunk_coords)

func set_tile(tile_coords: Vector2, tile_data):
	tiles[tile_coords] = tile_data

func get_tile(tile_coords: Vector2):
	return tiles[tile_coords]
	
func set_tile_walkable(tile_coords: Vector2, walkable):
	tile_walkable[tile_coords] = walkable

func get_tile_walkable(tile_coords: Vector2):
	return tile_walkable[tile_coords]

static func get_tile_boundaries(tile: Vector2):
	var top_left = Vector2(
		tile.x - 8,
		tile.y - 8,
	)
	var top_right = Vector2(
		tile.x + 8,
		tile.y - 8,
	)
	var bottom_right = Vector2(
		tile.x + 8,
		tile.y + 8,
	)
	var bottom_left = Vector2(
		tile.x - 8,
		tile.y + 8,
	)
	return [top_left, top_right, bottom_right, bottom_left]
