extends Panel


var map: Map
var hovered_tile: TileData

func _ready():
	map = get_tree().get_first_node_in_group("map")

func _process(delta):
	if map.tile_map != null:
		var mouse_pos = map.tile_map.get_local_mouse_position()
		var tile_pos = map.tile_map.local_to_map(mouse_pos)
		var local_tile_pos = map.tile_map.map_to_local(tile_pos)
		var tile = map.tile_map.get_cell_tile_data(0, tile_pos)
		
		if hovered_tile != tile:
			hovered_tile = tile
		if hovered_tile != null:
			set_size(Vector2(16, 16))
			set_position(local_tile_pos - Vector2(8, 8))
			
		queue_redraw()

func _draw():
	if map.tile_map != null:
		var hovered_tile = map.tile_map.map_to_local(map.tile_map.local_to_map(get_global_mouse_position()))
		var hover_color = Color.BLACK
		hover_color.a = 0.10
	#	draw_polygon(
	#		PackedVector2Array(Chunk.get_tile_boundaries(hovered_tile)),
	#		PackedColorArray(
	#			[hover_color],
	#		)
	#	)
