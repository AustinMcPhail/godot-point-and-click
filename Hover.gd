extends Node2D

@onready var player = $"../Player"
@onready var tile_map = $"../TileMap"

func _process(delta):
	queue_redraw()

func _draw():
	var hovered_tile = tile_map.map_to_local(tile_map.local_to_map(get_global_mouse_position()))
	var hover_color = Color.BLACK
	hover_color.a = 0.25
	draw_polygon(
		PackedVector2Array(player.get_tile_boundaries(hovered_tile)),
		PackedColorArray(
			[hover_color],
		)
	)
