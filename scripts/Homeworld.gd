class_name Homeworld

extends Node2D

@export var chunk_size : int = 15
@export var render_distance_in_chunks : int = 1
@export var max_map_height_in_chunks : int = 5
@export var max_map_width_in_chunks : int = 10



@export var seed = "Hello World"
@export var noise_height_texture: NoiseTexture2D
var noise: Noise

var spawn_chunk: Vector2 = Vector2.ZERO
var current_chunk

var temperature = {}
var altitude = {}
var trees = {}

var tile_map_layer = 0

var spawn_chunk_candidates = []

var source_id = 2

var DIRT_CELLS = [Vector2i(29, 1),Vector2i(29, 2),Vector2i(29, 3),Vector2i(29, 4)]
var GRASS_CELLS = [Vector2i(27, 6),Vector2i(27, 7),Vector2i(27, 8),Vector2i(27, 9)]
var SAND_CELLS = [Vector2i(14, 1),Vector2i(14, 2),Vector2i(14, 3),Vector2i(14, 4)]
var WATER_CELLS = [Vector2i(11, 19),Vector2i(12, 19),Vector2i(13, 19),Vector2i(14, 19)]

var water_tiles = []
var grass_terrain_id = 0
var grass_tiles = []
var sand_terrain_id = 1
var sand_tiles = []
var dirt_tiles = []

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

var rendered_chunks = []

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
#	set_loaded_tiles()
	pass
	
func _init():
	position = Vector2.ZERO;
	grid.cell_size = Vector2(16, 16)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER

func _ready():
	noise = noise_height_texture.noise
	noise.seed = seed.hash()
	var spawn_tile = Vector2(8, 8)
	var spawn_tile_in_chunk_pos = Vector2.ZERO + Vector2(
		floor(chunk_size / 2),
		floor(chunk_size / 2)
	)
	player.position = tile_map.map_to_local(spawn_tile_in_chunk_pos)
	generate_world()

func generate_world():
	var noise_val_arr = []
	for cx in range(-max_map_height_in_chunks, max_map_height_in_chunks):
		for cy in range(-max_map_width_in_chunks, max_map_width_in_chunks):
			for tx in chunk_size:
				for ty in chunk_size:
					var pos = Vector2(tx + (cx * chunk_size), ty + (cy * chunk_size));
					var noise_value = noise.get_noise_2d(pos.x, pos.y)
					noise_val_arr.append(noise_value)
					altitude[pos] = noise_value;
					if noise_value >= 0.0:
						if noise_value > 0.02:
							grass_tiles.append(pos)
						sand_tiles.append(pos)
					tile_map.set_cell(water_layer, pos, source_id, WATER_CELLS[0])
	tile_map.set_cells_terrain_connect(ground_layer_1, sand_tiles, sand_terrain_id, 0)
	tile_map.set_cells_terrain_connect(ground_layer_2, grass_tiles, grass_terrain_id, 0)

func load_chunk(cx, cy):
	var chunk = Chunk.new()
	chunk.set_coords(Vector2(cx, cy))
	var spawn_chunk_candidate = true
	for tx in chunk_size:
		for ty in chunk_size:
			var tile_data = []
			var pos = Vector2(tx + (cx * chunk_size), ty + (cy * chunk_size))
			if !altitude.has(pos):
				continue
			var alt = altitude[pos]
			chunk.set_tile_walkable(pos, true)
			if alt < 0.0:
				spawn_chunk_candidate = false
				tile_data.append([0, pos, 2, WATER_CELLS[randi_range(0, WATER_CELLS.size() - 1)]])
				chunk.set_tile_walkable(pos, false)
			elif alt > 0.0 && alt < 0.02:
				tile_data.append([0, pos, 2, SAND_CELLS[randi_range(0, SAND_CELLS.size() - 1)]])				
			elif alt > 0.4 && alt < 0.45:
				tile_data.append([0, pos, 2, DIRT_CELLS[randi_range(0, DIRT_CELLS.size() - 1)]])
			else:
				if (has_tree(pos)):
					tile_data.append([1, pos, 3, Vector2i.ZERO, 1])
					chunk.set_tile_walkable(pos, false)
				tile_data.append([0, pos, 2, GRASS_CELLS[randi_range(0, GRASS_CELLS.size() - 1)]])
			chunk.set_tile(pos, tile_data)
			tile_chunk_map[pos] = chunk
	if spawn_chunk_candidate:
		spawn_chunk_candidates.push_back(Vector2(cx, cy))
	chunk_loader.add_chunk(chunk.coords, chunk)
	return chunk

func set_loaded_tiles():
	var player_map_position = tile_map.local_to_map(player.position)	
	var _current_chunk = tile_chunk_map[Vector2(player_map_position)]
	if current_chunk == _current_chunk:
		return

#	tile_map.clear()

	var player_position = player.position
	current_chunk = _current_chunk
	var loaded = [current_chunk]
	var adjacent_chunk_pos = [current_chunk.coords]
	var render_range = render_distance_in_chunks
	for w in range(render_range):
		for h in range(render_range):
			var top_left = Vector2(current_chunk.coords.x - w, current_chunk.coords.y - h)
			var top = Vector2(current_chunk.coords.x, current_chunk.coords.y - h)
			var top_right = Vector2(current_chunk.coords.x + w, current_chunk.coords.y - h)
			var left = Vector2(current_chunk.coords.x - w, current_chunk.coords.y)
			var right = Vector2(current_chunk.coords.x + w, current_chunk.coords.y)
			var bottom_left = Vector2(current_chunk.coords.x - w, current_chunk.coords.y + h)
			var bottom = Vector2(current_chunk.coords.x, current_chunk.coords.y + h)
			var bottom_right = Vector2(current_chunk.coords.x + w, current_chunk.coords.y + h)
			adjacent_chunk_pos.append_array([
				top_left,
				top,
				top_right,
				right,
				bottom_right,
				bottom,
				bottom_left,
				left
			])
	
	for pos in adjacent_chunk_pos:
		if !chunk_loader.loaded_chunks.has(pos):
			loaded.append(load_chunk(pos.x, pos.y))
		else:
			loaded.append(chunk_loader.loaded_chunks[pos])
	
	for chunk in loaded:
		for tile_pos in chunk.tiles:
			var tile_data = chunk.get_tile(tile_pos)
			for data in tile_data:
				var layer = data[0]
				var pos = data[1]
				var src = data[2]
				var tile = data[3]
				if tile == Vector2i.ZERO:
					var alt = data[4]
					tile_map.set_cell(layer, pos, src, tile, alt)
				else:
					tile_map.set_cell(layer, pos, src, tile)

	grid.region = Rect2i(tile_map.get_used_rect().position, tile_map.get_used_rect().size)
	grid.update()
	for chunk in loaded:
		for tile_pos in chunk.tiles:
			var tile_walkable = chunk.get_tile_walkable(tile_pos)
			grid.set_point_solid(tile_pos, !tile_walkable)
func has_tree(pos):
	if !trees.has(pos):
		return false
	return trees[pos] > 0.1 && trees[pos] < 0.11 
