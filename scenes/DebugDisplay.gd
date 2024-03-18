extends VBoxContainer

var global_coords: Label
var chunk_coords: Label
var tile_coords: Label

var homeworld: Homeworld

func _init():
	global_coords = Label.new()
	add_child(global_coords)
	
	tile_coords = Label.new()
	add_child(tile_coords)
	
func _ready():
	homeworld = get_tree().get_first_node_in_group("homeworld")

func _process(delta):
	global_coords.text = "Global: " + str(homeworld.tile_map.get_local_mouse_position())
	tile_coords.text = "Tile: " + str(homeworld.tile_map.hovered_cell)
