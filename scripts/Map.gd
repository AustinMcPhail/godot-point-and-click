class_name Chunk

extends TileMap

var grid: AStarGrid2D
var hovered_cell

@onready var container: PanelContainer = $"PanelContainer"
@onready var label: Label = $"PanelContainer/Label"

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
	
func update():
	container.custom_minimum_size = get_used_rect().size * Vector2i(16, 16)
	container.size = get_used_rect().size * Vector2i(16, 16)
	label.text = "Hello"

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
