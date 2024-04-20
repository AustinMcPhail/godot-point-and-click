class_name Navigation

var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var target_pos: Vector2
var current_tile: Vector2
var previous_tile: Vector2

var map: Map
var node: Node2D
var speed: float = 1.0
var show_path: bool = false
var weight: float = 0.0
var moveable: bool = true
var solid = false

func _init(_map: Map, _node: Node2D):
	map = _map
	node = _node
	node.add_to_group("navigation")
	
func set_weight(_weight: float):
	weight = _weight
	
func set_speed(_speed: float):
	speed = _speed
	
func set_solid(_solid: bool):
	solid = _solid
	
func set_moveable(_moveable: bool):
	moveable = _moveable

func physics_process(delta):
	if current_tile != get_tile_position():
		previous_tile = current_tile
		current_tile = get_tile_position()
		#if solid == true:
			#if previous_tile != null:
				#map.grid.set_point_solid(previous_tile, false)
			#map.grid.set_point_solid(current_tile, true)

	if moveable:
		if !current_id_path.is_empty():
			target_pos = map.tile_map.map_to_local(current_id_path.front())
		if target_pos != Vector2.ZERO:
			node.global_position = node.global_position.move_toward(target_pos, speed)
			if node.global_position == target_pos:
				current_id_path.pop_front()
				if current_point_path.is_empty() == false:
					current_point_path.remove_at(0)
				if current_id_path.is_empty() == false:
					target_pos = map.tile_map.map_to_local(current_id_path.front())
				else:
					target_pos = Vector2.ZERO
					current_point_path = []

func handle_move_to(position: Vector2, range: int = 0):
	var clicked_tile = map.tile_map.local_to_map(position);
	var reset_target_to_solid = false
	#if (grid.is_point_solid(clicked_tile)):
		#var tile_data = map.tile_map.get_cell_tile_data(0, clicked_tile)
		#reset_target_to_solid = true
		#grid.set_point_solid(map.tile_map.local_to_map(position), false)
	var path = get_path_to(position, range)
	var id_path = path[0]
	var point_path = path[1]
	if id_path.is_empty() == false:
		#if reset_target_to_solid:
			#id_path.pop_back()
		current_id_path = id_path
		current_point_path = point_path
		for i in current_point_path.size():
			current_point_path[i] = current_point_path[i] + Vector2(8, 8)
	#if (reset_target_to_solid):
		#grid.set_point_solid(map.tile_map.local_to_map(position), true)

func get_path_to(position: Vector2, range: int = 0):
	var id_path: Array[Vector2i]
	var point_path: PackedVector2Array
	if target_pos != Vector2.ZERO:
		id_path = map.grid.get_id_path(
			map.tile_map.local_to_map(target_pos),
			map.tile_map.local_to_map(position)
		)
		point_path = map.grid.get_point_path(
			map.tile_map.local_to_map(target_pos),
			map.tile_map.local_to_map(position)
		)
	else:
		id_path = map.grid.get_id_path(
			map.tile_map.local_to_map(node.global_position),
			map.tile_map.local_to_map(position)
		).slice(1)
		point_path = map.grid.get_point_path(
			map.tile_map.local_to_map(node.global_position),
			map.tile_map.local_to_map(position)
		)
	for i in range:
		if id_path.size() > 0:
			id_path.pop_back()
		if point_path.size() > 0:
			point_path.remove_at(point_path.size() - 1)
	return [id_path, point_path]
	

func draw():
	if show_path == true:
		if current_point_path.is_empty():
			return
		if !target_pos:
			return
		map.draw_polyline(
			current_point_path, 
			Color.REBECCA_PURPLE
		)
		var target_tile_bounds = Chunk.get_tile_boundaries(target_pos)
		target_tile_bounds.append(target_tile_bounds.front())
		map.draw_polyline(
			PackedVector2Array(target_tile_bounds),
			Color.CYAN
		)

func get_tile_position() -> Vector2:
	return map.tile_map.local_to_map(node.position)
