extends CharacterBody2D

@export var wander_range = 1
@export var line_of_sight = 10
@export var threat_area_size = 2
@export var max_health = 10
var map: Map
var player_speech
var player: Player

var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var target_pos: Vector2 = Vector2.ZERO
var previous_pos: Vector2 = Vector2.ZERO
var spawn_tile: Vector2 = Vector2.ZERO

var current_tile
var previous_tile

var time = 0
var wander_timer = 0
var TIME_PERIOD = 1

var cursor = Input.CURSOR_POINTING_HAND

var threat

@onready var threat_area: Area2D = $"ThreatArea"
@onready var threat_area_shape: CollisionShape2D = $"ThreatArea/CollisionShape2D"
@onready var health_bar: TextureProgressBar = $"TextureProgressBar"
@onready var pointer

func _ready():
	player_speech = get_tree().get_first_node_in_group("player_speech")
	player = get_tree().get_first_node_in_group("player")
	map = get_tree().get_first_node_in_group("map")
	pointer = get_tree().get_first_node_in_group("pointer")
	spawn_tile = get_tile_position()
	health_bar.max_value = max_health
	health_bar.value = max_health
	threat_area_shape.shape.size = Vector2(
		16 * threat_area_size, 
		16 * threat_area_size
	)
	threat_area.body_entered.connect(something_enter_threat_area)
	threat_area.body_exited.connect(something_exit_threat_area)
	
func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("RightMouse"):
			pointer.open_context_menu(self, event.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_tile != get_tile_position():
		previous_tile = current_tile
		current_tile = get_tile_position()
		map.grid.set_point_solid(current_tile, true)
		if previous_tile != null:
			map.grid.set_point_solid(previous_tile, false)
	
	if threat == null && current_id_path.is_empty():
		wander_timer = wander_timer + delta
		if wander_timer > TIME_PERIOD * 2:
			find_new_target_pos()
			wander_timer = 0
		return
	elif threat != null:
		var distance_from_player = Vector2.ZERO.distance_to(threat.position - position)
		var line_of_sight_in_tiles = line_of_sight * 16
		if distance_from_player <= line_of_sight_in_tiles:
			set_target(threat.get_tile_position())
			current_id_path.pop_back()
		else:
			find_new_target_pos()
			threat = null
	if threat != null:
		if Vector2.ZERO.distance_to(threat.position - position) < 16:
			set_target(map.tile_map.local_to_map(previous_pos))
	
	if !current_id_path.is_empty():
		if (target_pos == Vector2.ZERO):
			target_pos = map.tile_map.map_to_local(current_id_path.front())
		global_position = global_position.move_toward(target_pos, 0.1)
		if global_position == target_pos:
			current_id_path.pop_front()
			if current_point_path.is_empty() == false:
				current_point_path.remove_at(0)
			if current_id_path.is_empty() == false:
				previous_pos = target_pos
				target_pos = map.tile_map.map_to_local(current_id_path.front())
			else:
				target_pos = Vector2.ZERO
				current_point_path = []
	queue_redraw()

	
func _mouse_enter():
	pointer.set_hovered(self)

func _mouse_exit():
	pointer.clear_hovered(self)
	
func _draw():
	if threat != null:
		draw_line(
			Vector2.ZERO,
			threat.position - position,
			Color.CYAN
		)

func find_new_target_pos():
	var rand_x = randi_range(spawn_tile.x - wander_range, spawn_tile.x + wander_range)
	var rand_y = randi_range(spawn_tile.y - wander_range, spawn_tile.y + wander_range)
	var pos = Vector2(rand_x, rand_y)
	set_target(pos)

func set_target(pos: Vector2):
	var id_path: Array[Vector2i]
	if target_pos != Vector2.ZERO:
		id_path = map.grid.get_id_path(
			map.tile_map.local_to_map(target_pos),
			pos
		)
		current_point_path = map.grid.get_point_path(
			map.tile_map.local_to_map(target_pos),
			pos
		)
	else:
		id_path = map.grid.get_id_path(
			map.tile_map.local_to_map(global_position),
			pos
		).slice(1)
		current_point_path = map.grid.get_point_path(
			map.tile_map.local_to_map(global_position),
			pos
		)
	if id_path.is_empty() == false:
		current_id_path = id_path
		for i in current_point_path.size():
			current_point_path[i] = current_point_path[i] + Vector2(8, 8)
	return
	
func get_tile_position() -> Vector2:
	return map.tile_map.local_to_map(position)
	
func something_enter_threat_area(body: PhysicsBody2D):
	if body == player:
		threat = player
		print("player entered threat area")
	
func something_exit_threat_area(body: PhysicsBody2D):
	if body == player:
		print("player exited threat area")
	
func get_context_label():
	return "Slime"
	
func examine():
	player_speech.say("Green and slimy.")

func get_context_menu():
	return [
		["Attack", func(): print("Attack")],
		["Examine", self.examine]
	]
