extends Node2D

@onready var player = $"../Player"
@onready var pointer = $"../Poi"
@onready var tile_map = $"../TileMap"

func _process(delta):
	queue_redraw()

func _draw():
	if player.current_point_path.is_empty():
		return
	if !player.target_pos:
		return
		
	draw_polyline(player.current_point_path, Color.REBECCA_PURPLE)
	var target_tile_bounds = player.get_tile_boundaries(player.target_pos)
	target_tile_bounds.append(target_tile_bounds.front())
	draw_polyline(
		PackedVector2Array(target_tile_bounds),
		Color.CYAN	
	)

