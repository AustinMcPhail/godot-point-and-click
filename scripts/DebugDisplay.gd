extends VBoxContainer

var global_coords: Label
var chunk_coords: Label
var tile_coords: Label

var tile_map: TileMap

func _init():
	global_coords = Label.new()
	add_child(global_coords)
	
	tile_coords = Label.new()
	add_child(tile_coords)
	
func _ready():
	tile_map = get_tree().get_first_node_in_group("map").tile_map

func _process(delta):
	if tile_map != null:
		global_coords.text = "Global: " + str(tile_map.get_local_mouse_position())
		tile_coords.text = "Tile: " + str(tile_map.local_to_map(tile_map.get_local_mouse_position()))
