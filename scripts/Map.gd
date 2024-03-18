class_name Map

extends TileMap

var grid: AStarGrid2D
var hovered_cell

func _init():
	add_to_group("map")


func _draw():
	hovered_cell = local_to_map(get_local_mouse_position())
	var hover_color = Color.BLACK
	hover_color.a = 0.10
	draw_polygon(
		PackedVector2Array(get_tile_boundaries(map_to_local(hovered_cell))),
		PackedColorArray(
			[hover_color],
		)
	)
	pass

func _process(delta):
	queue_redraw()

static func get_tile_boundaries(tile: Vector2):
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
