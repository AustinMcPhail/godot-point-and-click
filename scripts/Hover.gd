extends Node2D

var player: Player

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	queue_redraw()

func _draw():
	var hovered_tile = player.map.map_to_local(player.map.local_to_map(get_global_mouse_position()))
	var hover_color = Color.BLACK
	hover_color.a = 0.10
	draw_polygon(
		PackedVector2Array(player.get_tile_boundaries(hovered_tile)),
		PackedColorArray(
			[hover_color],
		)
	)
