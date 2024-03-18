class_name Homeworld

extends Node2D

@export var alt_freq: float = 0.005
@export var oct : int = 4
@export var lac : int = 2
@export var gain : float = 0.5
@export var amplitude : float = 1.0
@export var chunk_size : int = 15
@export var map_size_in_chunks : int = 1

var spawn_chunk: Vector2 = Vector2.ZERO
var map_size: Vector2 = Vector2.ZERO

var noise_map: FastNoiseLite
const CHUNK_MAP = {}
var temperature = {}
var altitude = {}
var trees = {}

var tile_map_layer = 0

var spawn_chunk_candidates = []

var GRASS_CELLS = [Vector2i(27, 6),Vector2i(27, 7),Vector2i(27, 8),Vector2i(27, 9)]
var WATER_CELLS = [Vector2i(11, 19),Vector2i(12, 19),Vector2i(13, 19),Vector2i(14, 19)]

@onready var tile_map: Map = $"TileMap"
@onready var player: Player = $"Player"

func _ready():
	spawn_chunk = Vector2(floor(map_size_in_chunks / 2), floor(map_size_in_chunks / 2))
	map_size = Vector2(
		map_size_in_chunks * chunk_size,
		map_size_in_chunks * chunk_size
	)
	var seed = Time.get_unix_time_from_system()
	var altitude_seed = randf_range(-seed, seed)
	var trees_seed = randf_range(-seed, seed)
	altitude = generate_map(altitude_seed, alt_freq, oct, lac, gain, FastNoiseLite.FRACTAL_FBM, FastNoiseLite.TYPE_PERLIN)
	trees = generate_map(trees_seed, alt_freq, oct, lac, gain, FastNoiseLite.FRACTAL_PING_PONG, FastNoiseLite.TYPE_SIMPLEX)
	set_tiles()
	tile_map.update_map()
	var spawn_chunk_idx = randi_range(0, spawn_chunk_candidates.size() - 1)
	spawn_chunk = spawn_chunk_candidates[spawn_chunk_idx]
	var spawn_tile = Vector2(
		spawn_chunk.x * chunk_size + floor(chunk_size / 2),
		spawn_chunk.y * chunk_size + floor(chunk_size / 2), 
	)
	var spawn_tile_blocked = has_tree(spawn_tile)
	while spawn_tile_blocked:
		spawn_chunk_candidates.remove_at(spawn_chunk_idx)
		spawn_chunk_idx = randi_range(0, spawn_chunk_candidates.size() - 1)
		spawn_chunk = spawn_chunk_candidates[spawn_chunk_idx]
		spawn_tile = Vector2(
			spawn_chunk.x * chunk_size + floor(chunk_size / 2),
			spawn_chunk.y * chunk_size + floor(chunk_size / 2), 
		)
		spawn_tile_blocked = has_tree(spawn_tile)
	print(spawn_tile, " => ", tile_map.map_to_local(spawn_tile))
	player.position = tile_map.map_to_local(spawn_tile)

func generate_map(noise_seed, frequency, octaves, lacunarity, gain, fractal_type, noise_type):
	noise_map = FastNoiseLite.new()
	noise_map.fractal_type = fractal_type
	noise_map.noise_type = noise_type
	noise_map.seed = noise_seed
	noise_map.frequency = frequency
	noise_map.fractal_octaves = octaves
	noise_map.fractal_lacunarity = lacunarity
	noise_map.fractal_gain = gain
	
	var map = {}
	var chunk_map = {}
	for cx in map_size_in_chunks:
		for cy in map_size_in_chunks:
			for tx in chunk_size:
				for ty in chunk_size:
					var rand = abs(noise_map.get_noise_2d(tx + (cx * chunk_size), ty + (cy * chunk_size)) * 2 - 1)
					map[Vector2(tx + (cx * chunk_size), ty + (cy * chunk_size))] = rand;
	return map
	
func set_tiles():
	for cx in map_size_in_chunks:
		for cy in map_size_in_chunks:
			var spawn_chunk_candidate = true
			for tx in chunk_size:
				for ty in chunk_size:
					var pos = Vector2(tx + (cx * chunk_size), ty + (cy * chunk_size))
#					var temp = temperature[pos]
					var tree = trees[pos]
					var alt = altitude[pos]
					if alt < 1:
						spawn_chunk_candidate = false
						tile_map.set_cell(0, pos, 2, WATER_CELLS[randi_range(0, WATER_CELLS.size() - 1)])
					else:
						if (has_tree(pos)):
							tile_map.set_cell(1, pos, 3, Vector2i.ZERO, 1)
						tile_map.set_cell(0, pos, 2, GRASS_CELLS[randi_range(0, GRASS_CELLS.size() - 1)])
			if spawn_chunk_candidate:
				spawn_chunk_candidates.push_back(Vector2(cx, cy))
				
func has_tree(pos):
	return trees[pos] < 0.1
