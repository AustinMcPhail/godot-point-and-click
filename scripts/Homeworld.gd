class_name Homeworld

extends Node2D

@export var chunk_size : int = 15
@export var initial_map_size_in_chunks : int = 3
@export var render_distance_in_chunks : int = 1
@export var max_map_height_in_chunks : int = 5
@export var max_map_width_in_chunks : int = 10

@export var seed: String = ""
@export var noise_height_texture: NoiseTexture2D
var noise: Noise
@export var tree_noise_height_texture: NoiseTexture2D
var tree_noise: Noise

var spawn_chunk: Vector2 = Vector2.ZERO
var current_chunk

var temperature = {}
var altitude = {}
var trees = {}

var tile_map_layer = 0

var spawn_chunk_candidates = []

var source_id = 2
var tree_source_id = 3

var DIRT_CELLS = [Vector2i(29, 1),Vector2i(29, 2),Vector2i(29, 3),Vector2i(29, 4)]
var GRASS_CELLS = [Vector2i(27, 6),Vector2i(27, 7),Vector2i(27, 8),Vector2i(27, 9)]
var SAND_CELLS = [Vector2i(14, 1),Vector2i(14, 2),Vector2i(14, 3),Vector2i(14, 4)]
var WATER_CELLS = [Vector2i(11, 19),Vector2i(12, 19),Vector2i(13, 19),Vector2i(14, 19)]

var water_tiles = []
var grass_terrain_id = 2
var grass_tiles = []
var sand_terrain_id = 1
var sand_tiles = []
var dirt_tiles = []
var solid_cells = []

# Layers
var water_layer = 0
var ground_layer_1 = 1
var ground_layer_2 = 2
var cliff_layer_1 = 3
var trees_layer = 4
var environment_layer = 5

var player_chunk

var loaded_coords = []
var chunk_data = []

var loaded_chunks = []

var tile_chunk_map = {}

@onready var tile_map: TileMap = $"TileMap"
@onready var player: Player = $"Player"
@onready var chunk_loader: Chunkloader = $"Chunkloader"
@onready var texture_rect: TextureRect = $"TextureRect"


var grid: AStarGrid2D = AStarGrid2D.new()

var altitude_seed
var trees_seed

func add_chunk(coords):
	loaded_coords.append(coords)
	chunk_data.append([])
	
func update_chunk(coords, chunk_data):
	chunk_data[loaded_coords.find(coords)] = chunk_data

func get_chunk_data(coords):
	var found_chunk_data = chunk_data[loaded_coords.find(coords)]
	return chunk_data
	
func _process(delta):
	generate_world(render_distance_in_chunks)
	
func _init():
	position = Vector2.ZERO;
	grid.cell_size = Vector2(16, 16)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER

func _ready():
	if seed == "":
		seed = Time.get_datetime_string_from_system()
	noise = noise_height_texture.noise
	noise.seed = seed.hash()
	tree_noise = tree_noise_height_texture.noise
	tree_noise.seed = seed.hash()
	generate_world(initial_map_size_in_chunks)

	var spawn_tile
	while spawn_tile == null:
		var tile = grass_tiles[randi_range(0, grass_tiles.size() - 1)]
		var tile_data = tile_map.get_cell_tile_data(ground_layer_1, tile)
		var environment_tile = tile_map.get_cell_alternative_tile(environment_layer, tile)
		print(environment_tile)
		if tile_data.get_custom_data("walkable") == true && environment_tile == -1:
			spawn_tile = tile

	player.position = tile_map.map_to_local(spawn_tile)

func generate_world(in_range: int):
	var player_tile = tile_map.local_to_map(player.position)
	var chunk_x = floor(player_tile.x / float(chunk_size))
	var chunk_y = floor(player_tile.y / float(chunk_size))
	var current_chunk = Vector2(chunk_x, chunk_y)
	if player_chunk == current_chunk:
		return
	player_chunk = current_chunk
	var chunks_to_load = get_chunks_to_load(player_chunk, in_range)
	loaded_chunks.append_array(chunks_to_load)
	if chunks_to_load.is_empty():
		return
	var noise_val_arr = []
	var tree_noise_val_arr = []
	grass_tiles = []
	sand_tiles = []
	for chunk in chunks_to_load:
		for tx in chunk_size:
			for ty in chunk_size:
				var pos = Vector2(tx + (chunk.x * chunk_size), ty + (chunk.y * chunk_size));
				var noise_value = noise.get_noise_2d(pos.x, pos.y)
				var tree_noise_value = tree_noise.get_noise_2d(pos.x, pos.y)
				noise_val_arr.append(noise_value)
				tree_noise_val_arr.append(tree_noise_value)
				altitude[pos] = noise_value;
				if noise_value >= 0.0:
					if noise_value > 0.02:
						if (has_tree(tree_noise_value)):
							solid_cells.append(pos)
							tile_map.set_cell(environment_layer, pos, tree_source_id, Vector2i.ZERO, 1)
						grass_tiles.append(pos)
					sand_tiles.append(pos)
				else:
					solid_cells.append(pos)
				tile_map.set_cell(water_layer, pos, source_id, WATER_CELLS[0])

	tile_map.set_cells_terrain_connect(ground_layer_1, sand_tiles, sand_terrain_id, 0)
	tile_map.set_cells_terrain_connect(ground_layer_2, grass_tiles, grass_terrain_id, 0)
	grid.region = Rect2i(tile_map.get_used_rect().position, tile_map.get_used_rect().size)
	grid.update()
	for pos in solid_cells:
		grid.set_point_solid(pos)

func get_chunks_to_load(current_chunk: Vector2, in_range: int):
	var adjacent_chunk_pos = []
	if !loaded_chunks.has(current_chunk):
		adjacent_chunk_pos = [current_chunk]
	var render_range = render_distance_in_chunks
	for w in range(0, in_range):
		for h in range(0, in_range):
			var top_left = Vector2(current_chunk.x - w, current_chunk.y - h)
			if !adjacent_chunk_pos.has(top_left) && !loaded_chunks.has(top_left):
				adjacent_chunk_pos.append(top_left)
			var top = Vector2(current_chunk.x, current_chunk.y - h)
			if !adjacent_chunk_pos.has(top) && !loaded_chunks.has(top):
				adjacent_chunk_pos.append(top)
			var top_right = Vector2(current_chunk.x + w, current_chunk.y - h)
			if !adjacent_chunk_pos.has(top_right) && !loaded_chunks.has(top_right):
				adjacent_chunk_pos.append(top_right)
			var left = Vector2(current_chunk.x - w, current_chunk.y)
			if !adjacent_chunk_pos.has(left) && !loaded_chunks.has(left):
				adjacent_chunk_pos.append(left)
			var right = Vector2(current_chunk.x + w, current_chunk.y)
			if !adjacent_chunk_pos.has(right) && !loaded_chunks.has(right):
				adjacent_chunk_pos.append(right)
			var bottom_left = Vector2(current_chunk.x - w, current_chunk.y + h)
			if !adjacent_chunk_pos.has(bottom_left) && !loaded_chunks.has(bottom_left):
				adjacent_chunk_pos.append(bottom_left)
			var bottom = Vector2(current_chunk.x, current_chunk.y + h)
			if !adjacent_chunk_pos.has(bottom) && !loaded_chunks.has(bottom):
				adjacent_chunk_pos.append(bottom)
			var bottom_right = Vector2(current_chunk.x + w, current_chunk.y + h)
			if !adjacent_chunk_pos.has(bottom_right) && !loaded_chunks.has(bottom_right):
				adjacent_chunk_pos.append(bottom_right)
	return adjacent_chunk_pos

func has_tree(value):
	return value <= 0.0
