class_name Player

extends Node2D

@export_category("Admin")
@export var skills: Skills


var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var target_pos: Vector2 = Vector2.ZERO
var action_node
@onready var inventory: Inventory = $"Inventory"
@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var camera: Camera2D = $"Camera2D"
var map: Map
var pointer: Pointer
var context_menu_entered = false
# Called when the node enters the scene tree for the first time.
func _ready():
	camera.zoom = Vector2(8, 8)
	map = get_tree().get_first_node_in_group("map")
	pointer = get_tree().get_first_node_in_group("pointer")
	pointer.context_menu_entered.connect(func(): context_menu_entered = true)
	pointer.context_menu_exited.connect(func(): context_menu_entered = false)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			camera.zoom = Vector2(min(camera.zoom.x + 1, 10), min(camera.zoom.y + 1, 10))
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			camera.zoom = Vector2(max(camera.zoom.x - 1, 2), max(camera.zoom.y - 1, 2))
	if (!context_menu_entered):
		if Input.is_action_just_pressed("LeftMouse"):
			handle_move_to(get_global_mouse_position())
	if Input.is_action_just_pressed("Inventory"):
		inventory.list_items()
	if Input.is_action_just_pressed("Player"):
		skills.list_skills()

func _physics_process(delta):
	update_animation_state()
	update_player_direction()

	if current_id_path.is_empty():
		if action_node != null and !action_node.is_started():
			action_node.start()
		return
		
	if (target_pos == Vector2.ZERO):
		target_pos = map.map_to_local(current_id_path.front())	
	global_position = global_position.move_toward(target_pos, 1)
	if global_position == target_pos:
		current_id_path.pop_front()
		if current_point_path.is_empty() == false:
			current_point_path.remove_at(0)
		if current_id_path.is_empty() == false:
			target_pos = map.map_to_local(current_id_path.front())
		else:
			target_pos = Vector2.ZERO
			current_point_path = []

func move_to_and_perform_action(node: Node2D):
	if (!context_menu_entered):
		handle_move_to(node.position)
		action_node = node
	
func handle_move_to(position: Vector2):
	pointer.close_context_menu()
	if action_node != null && action_node.is_started():
		action_node.stop()
		action_node = null

	var clicked_tile = map.local_to_map(position);
	var reset_target_to_solid = false
	var grid = map.grid
	
	if (grid.is_point_solid(clicked_tile)):
		var tile_data = map.get_cell_tile_data(0, clicked_tile)
		reset_target_to_solid = true
		grid.set_point_solid(map.local_to_map(position), false)
			
	var id_path: Array[Vector2i]
	if target_pos != Vector2.ZERO:
		id_path = grid.get_id_path(
			map.local_to_map(target_pos),
			map.local_to_map(position)
		)
		current_point_path = grid.get_point_path(
			map.local_to_map(target_pos),
			map.local_to_map(position)
		)
	else:			
		id_path = grid.get_id_path(
			map.local_to_map(global_position),
			map.local_to_map(position)
		).slice(1)
		current_point_path = grid.get_point_path(
			map.local_to_map(global_position),
			map.local_to_map(position)
		)
	if id_path.is_empty() == false:
		if reset_target_to_solid:
			id_path.pop_back()
		current_id_path = id_path
		for i in current_point_path.size():
			current_point_path[i] = current_point_path[i] + Vector2(8, 8)
			
	if (reset_target_to_solid):
		grid.set_point_solid(map.local_to_map(position), true)

func stop_actions():
	if action_node != null:
		action_node.stop()
		action_node = null

func complete_action(exp: Dictionary, result: Dictionary):
	skills.add_exp(exp)
	inventory.add_items(result);
	
func update_animation_state():
	if (current_id_path.is_empty() == false):
		sprite.play("move")
	else:
		sprite.play("default")

func update_player_direction():
	if current_id_path.is_empty() == false && target_pos.x < position.x:
		sprite.flip_h = true
	elif current_id_path.is_empty() == false && target_pos.x > position.x:
		sprite.flip_h = false
