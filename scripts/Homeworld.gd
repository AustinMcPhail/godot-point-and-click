class_name Homeworld

extends Node2D

@export var seed = ""
@export var alt_freq: float = 0.005
const MAX_FREQ = 0.005
@export var oct : int = 4
@export var lac : float = 3
@export var gain : float = 0.5
@export var amplitude : float = 1.0
@export var chunk_size : int = 15
@export var map_size_in_chunks : int = 1
@export var render_distance_in_chunks : int = 1

@export var max_map_height_in_chunks : int = 5
@export var max_map_width_in_chunks : int = 10

var spawn_chunk: Vector2 = Vector2.ZERO
var current_chunk

var temperature = {}
var altitude = {}
var trees = {}

var tile_map_layer = 0

var spawn_chunk_candidates = []

var DIRT_CELLS = [Vector2i(14, 1),Vector2i(14, 2),Vector2i(14, 3),Vector2i(14, 4)]
var GRASS_CELLS = [Vector2i(27, 6),Vector2i(27, 7),Vector2i(27, 8),Vector2i(27, 9)]
var WATER_CELLS = [Vector2i(11, 19),Vector2i(12, 19),Vector2i(13, 19),Vector2i(14, 19)]

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
	set_loaded_tiles()
	
func _init():
	grid.cell_size = Vector2(16, 16)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER

func _ready():
	altitude_seed = seed.hash()
	trees_seed = seed.hash()
	for cx in range(-max_map_height_in_chunks, max_map_height_in_chunks):
		for cy in range(-max_map_width_in_chunks, max_map_width_in_chunks):
				var min = 3
				var distance_from_center = Vector2.ZERO.distance_to(Vector2(cx, cy))
				var freq = min((distance_from_center / 3) / 100, MAX_FREQ)
				
				generate_map(altitude, "alt", cx, cy, altitude_seed, freq, oct, lac, gain, FastNoiseLite.FRACTAL_FBM, FastNoiseLite.TYPE_PERLIN)
				generate_map(trees, "trees", cx, cy, trees_seed, 0.01, oct, 10, gain, FastNoiseLite.FRACTAL_PING_PONG, FastNoiseLite.TYPE_SIMPLEX)
	
	position = Vector2.ZERO
	load_chunk(0, 0)
	var spawn_tile = Vector2(
		8, 8 
	)
	var spawn_tile_in_chunk_pos = Vector2.ZERO + Vector2(
		floor(chunk_size / 2),
		floor(chunk_size / 2)
	)
	player.position = tile_map.map_to_local(spawn_tile_in_chunk_pos)

func generate_map(map, label, cx, cy, noise_seed, frequency, octaves, lacunarity, gain, fractal_type, noise_type):
	var noise_map = FastNoiseLite.new()
	noise_map.fractal_type = fractal_type
	noise_map.noise_type = noise_type
	noise_map.seed = noise_seed
	noise_map.frequency = frequency
	noise_map.fractal_octaves = octaves
	noise_map.fractal_lacunarity = lacunarity
	noise_map.fractal_gain = gain
	
	noise_map.get_image(500, 500).save_jpg("/" + label + ".jpg")

	for tx in chunk_size:
		for ty in chunk_size:
			var rand = abs(noise_map.get_noise_2d(tx + (cx * chunk_size), ty + (cy * chunk_size)) * 2 - 1)
			map[Vector2(tx + (cx * chunk_size), ty + (cy * chunk_size))] = rand;

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
			if alt < 0.75:
				spawn_chunk_candidate = false
				tile_data.append([0, pos, 2, WATER_CELLS[randi_range(0, WATER_CELLS.size() - 1)]])
				chunk.set_tile_walkable(pos, false)
			elif alt > 1.5:
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
	var render_range = 2
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
	return trees[pos] < 0.25
