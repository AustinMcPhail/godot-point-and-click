class_name Map

extends Node2D

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

var source_id = 2
var tree_source_id = 3

# Layers
var water_layer = 0
var ground_layer_1 = 1
var ground_layer_2 = 2
var cliff_layer_1 = 3
var trees_layer = 4
var environment_layer = 5


@onready var tile_map: TileMap = $"TileMap"
var grid: AStarGrid2D = AStarGrid2D.new()
var player: Player

func _init():
	grid.cell_size = Vector2(16, 16)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES

func _process(delta):
	queue_redraw()
	
func _draw():
	for node in get_tree().get_nodes_in_group("navigation"):
		node.navigation.draw()

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player")
	grid.region = Rect2i(tile_map.get_used_rect().position, tile_map.get_used_rect().size)
	grid.update()
	pass # Replace with function body.
