extends VBoxContainer

var global_coords: Label
var chunk_coords: Label
var tile_coords: Label

var map: Map

func _init():
	global_coords = Label.new()
	add_child(global_coords)
	
	tile_coords = Label.new()
	add_child(tile_coords)
	
func _ready():
	map = get_tree().get_first_node_in_group("map")

func _process(delta):
	global_coords.text = "Global: " + str(map.get_local_mouse_position())
	tile_coords.text = "Tile: " + str(map.hovered_cell)
