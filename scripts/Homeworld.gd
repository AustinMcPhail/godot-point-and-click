class_name Homeworld

extends Node2D

@export var alt_freq: float = 0.005
@export var oct : int = 4
@export var lac : int = 2
@export var gain : float = 0.5
@export var amplitude : float = 1.0
@export var chunk_size : int = 15
@export var map_size_in_chunks : int = 5

var SPAWN_CHUNK = Vector2(floor(map_size_in_chunks / 2), floor(map_size_in_chunks / 2))
var MAP_SIZE = Vector2(
	map_size_in_chunks * chunk_size,
	map_size_in_chunks * chunk_size
)

var noise_map: FastNoiseLite
const CHUNK_MAP = {}
var temperature = {}
var altitude = {}
var trees = {}

var tile_map_layer = 0

var GRASS_CELLS = [Vector2i(27, 6),Vector2i(27, 7),Vector2i(27, 8),Vector2i(27, 9)]
var WATER_CELLS = [Vector2i(11, 19),Vector2i(12, 19),Vector2i(13, 19),Vector2i(14, 19)]

@onready var tile_map: Map = $"TileMap"
@onready var player: Player = $"Player"

func generate_map(noise_seed, frequency, octaves, lacunarity, gain):
	noise_map = FastNoiseLite.new()
	noise_map.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise_map.noise_type = FastNoiseLite.TYPE_PERLIN
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
					var rand = abs(noise_map.get_noise_2d(tx + (cx * chunk_size), ty + (cy * chunk_size)) * 2 - 1 )
					map[Vector2(tx + (cx * chunk_size), ty + (cy * chunk_size))] = rand;
	return map
	
func set_tiles():
	for cx in map_size_in_chunks:
		for cy in map_size_in_chunks:
			for tx in chunk_size:
				for ty in chunk_size:
					var pos = Vector2(tx + (cx * chunk_size), ty + (cy * chunk_size))
#					var temp = temperature[pos]
#					var tree = trees[pos]
					var is_spawn_chunk = Vector2(cx, cy) == SPAWN_CHUNK
					if (!is_spawn_chunk):
						var alt = altitude[pos]
						if alt < 1:
							tile_map.set_cell(0, pos, 2, WATER_CELLS[randi_range(0, WATER_CELLS.size() - 1)])
						else:
							tile_map.set_cell(0, pos, 2, GRASS_CELLS[randi_range(0, GRASS_CELLS.size() - 1)])
#						if (tree < 1):
#							tile_map.set_cell(1, pos, 3, Vector2i.ZERO, 1)
					else:
						tile_map.set_cell(0, pos, 2, GRASS_CELLS[randi_range(0, GRASS_CELLS.size() - 1)])

func _ready():
	print(map_size_in_chunks)
#	temperature = generate_map(Time.get_unix_time_from_system(), alt_freq, oct, lac, gain)
	altitude = generate_map(Time.get_unix_time_from_system(), alt_freq, oct, lac, gain)
#	trees = generate_map(Time.get_unix_time_from_system(), alt_freq, oct, lac, gain)
	set_tiles()
	tile_map.update_map()
	var center = tile_map.map_to_local(floor(MAP_SIZE / 2))
	var map_rect = tile_map.get_used_rect()
	map_rect.position = map_rect.position * Vector2i(16, 16)
	map_rect.size = map_rect.size * Vector2i(16, 16)
	player.position = map_rect.size / 2
