extends Panel

var homeworld: Homeworld

var hovered_tile: TileData

func _ready():
	homeworld = get_tree().get_first_node_in_group("homeworld")

func _process(delta):
	var tile_map = homeworld.tile_map
	var mouse_pos = tile_map.get_local_mouse_position()
	print("mouse pos: ", mouse_pos)
	var tile_pos = tile_map.local_to_map(mouse_pos)
	print("tile pos: ", tile_pos)
	var local_tile_pos = tile_map.map_to_local(tile_pos)
	print("local tile pos: ", local_tile_pos)
	var global_tile_pos = homeworld.to_global(local_tile_pos)
	print("global tile pos?: ", global_tile_pos)
	var tile = tile_map.get_cell_tile_data(0, tile_pos)
	print("tile: ", tile)
	print("position", position)
	
	if hovered_tile != tile:
		hovered_tile = tile
	if hovered_tile != null:
		set_size(Vector2(16, 16))
		set_position(local_tile_pos - Vector2(8, 8))
		
	queue_redraw()

func _draw():
	var hovered_tile = homeworld.tile_map.map_to_local(homeworld.tile_map.local_to_map(get_global_mouse_position()))
	var hover_color = Color.BLACK
	hover_color.a = 0.10
#	draw_polygon(
#		PackedVector2Array(Chunk.get_tile_boundaries(hovered_tile)),
#		PackedColorArray(
#			[hover_color],
#		)
#	)
