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

var player_chunk

var loaded_coords = []
var chunk_data = []

var loaded_chunks = []

var tile_chunk_map = {}

@onready var map: Map = $"Map"
@onready var player: Player = $"Player"
@onready var texture_rect: TextureRect = $"TextureRect"

var altitude_seed
var trees_seed
var tile_map: TileMap
var grid: AStarGrid2D

func _init():
	position = Vector2.ZERO;

func _ready():
	tile_map = map.tile_map
	grid = map.grid
	
	if seed == "":
		seed = Time.get_datetime_string_from_system()
	noise = noise_height_texture.noise
	noise.seed = seed.hash()
	tree_noise = tree_noise_height_texture.noise
	tree_noise.seed = seed.hash()
	generate_world(initial_map_size_in_chunks)

	var spawn_tile
	while spawn_tile == null:
		var tile = map.grass_tiles[randi_range(0, map.grass_tiles.size() - 1)]
		var tile_data = tile_map.get_cell_tile_data(map.ground_layer_1, tile)
		var environment_tile = tile_map.get_cell_alternative_tile(map.environment_layer, tile)
		print(environment_tile)
		if tile_data.get_custom_data("walkable") == true && environment_tile == -1:
			spawn_tile = tile

	player.position = tile_map.map_to_local(spawn_tile)
	
func _process(delta):
	generate_world(render_distance_in_chunks)
	
func add_chunk(coords):
	loaded_coords.append(coords)
	chunk_data.append([])
	
func update_chunk(coords, chunk_data):
	chunk_data[loaded_coords.find(coords)] = chunk_data

func get_chunk_data(coords):
	var found_chunk_data = chunk_data[loaded_coords.find(coords)]
	return chunk_data

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
	map.grass_tiles = []
	map.sand_tiles = []
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
							map.solid_cells.append(pos)
							tile_map.set_cell(map.environment_layer, pos, map.tree_source_id, Vector2i.ZERO, 1)
						map.grass_tiles.append(pos)
					map.sand_tiles.append(pos)
				else:
					map.solid_cells.append(pos)
				tile_map.set_cell(map.water_layer, pos, map.source_id, map.WATER_CELLS[0])

	tile_map.set_cells_terrain_connect(map.ground_layer_1, map.sand_tiles, map.sand_terrain_id, 0)
	tile_map.set_cells_terrain_connect(map.ground_layer_2, map.grass_tiles, map.grass_terrain_id, 0)
	grid.region = Rect2i(tile_map.get_used_rect().position, tile_map.get_used_rect().size)
	grid.update()
	for pos in map.solid_cells:
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
