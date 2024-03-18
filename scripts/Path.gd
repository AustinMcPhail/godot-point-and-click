extends Node2D

var player: Player

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	queue_redraw()

func _draw():
	if player.current_point_path.is_empty():
		return
	if !player.target_pos:
		return
		
	draw_polyline(player.current_point_path, Color.REBECCA_PURPLE)
	var target_tile_bounds = Chunk.get_tile_boundaries(player.target_pos)
	target_tile_bounds.append(target_tile_bounds.front())
	draw_polyline(
		PackedVector2Array(target_tile_bounds),
		Color.CYAN	
	)

