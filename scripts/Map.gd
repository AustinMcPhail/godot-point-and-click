class_name Map

extends TileMap

var grid: AStarGrid2D

func _init():
	add_to_group("map")

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = AStarGrid2D.new()
	grid.region = get_used_rect()
	grid.cell_size = Vector2(16, 16)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()


func _draw():
	var clicked_cell = map_to_local(local_to_map(get_local_mouse_position()))
	var hover_color = Color.BLACK
	hover_color.a = 0.10
	draw_polygon(
		PackedVector2Array(get_tile_boundaries(clicked_cell)),
		PackedColorArray(
			[hover_color],
		)
	)
#	for cell in get_used_cells(1):
#		if cell.x == clicked_cell.x && cell.y == clicked_cell.y:
#			print(get_cell_tile_data(1, cell))
#	var data = get_cell_tile_data(1, clicked_cell)
#	if tile_data is TileData:
#		var hover_color = Color.BLACK
#		hover_color.a = 0.10
#		draw_polygon(
#			PackedVector2Array(get_tile_boundaries(tile_pos)),
#			PackedColorArray(
#				[hover_color],
#			)
#		)
	pass

func _process(delta):
	queue_redraw()
#	var mouse_pos_global = get_global_mouse_position()
#	var mouse_pos_local = to_local(mouse_pos_global)
#	var tile_pos = local_to_map(mouse_pos_local)
#	var tile_data = get_cell_tile_data(0, tile_pos)
#	if tile_data != null:
#		print(tile_data)
#	pass

func get_tile_boundaries(tile: Vector2):
	var top_left = Vector2(
		tile.x - 8,
		tile.y - 8,
	)
	var top_right = Vector2(
		tile.x + 8,
		tile.y - 8,
	)
	var bottom_right = Vector2(
		tile.x + 8,
		tile.y + 8,
	)
	var bottom_left = Vector2(
		tile.x - 8,
		tile.y + 8,
	)
	return [top_left, top_right, bottom_right, bottom_left]
