extends CharacterBody2D
class_name Player

@export_category("Admin")
@export var skills: PlayerSkills
@export var inventory: PlayerInventory
@export var show_map : bool = false

@onready var sprite: PlayerSprite = $"PlayerSprite"
@onready var main_hand: TextureRect = $MainHand

var action_node
var camera: Camera2D
var pointer: Pointer
var current_zoom = Vector2(8, 8)
var current_offset: Vector2
var map: Map
var navigation: Navigation

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_tree().get_first_node_in_group("camera")
	pointer = get_tree().get_first_node_in_group("pointer")
	map = get_tree().get_first_node_in_group("map")
	navigation = Navigation.new(map, self)
	navigation.set_speed(1.0)
	navigation.show_path = true
	main_hand.texture = inventory.main_hand.texture
	camera.zoom = current_zoom
	current_offset = camera.offset

func _unhandled_input(event):
	if !show_map:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				camera.zoom = Vector2(min(camera.zoom.x + 1, 10), min(camera.zoom.y + 1, 10))
				current_zoom = camera.zoom
				current_offset = camera.offset
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				camera.zoom = Vector2(max(camera.zoom.x - 1, 2), max(camera.zoom.y - 1, 2))
				current_zoom = camera.zoom
				current_offset = camera.offset
	if Input.is_action_just_pressed("LeftMouse"):
		pointer.close_context_menu()
		if action_node != null && action_node.is_started():
			action_node.stop()
			action_node = null
		navigation.handle_move_to(get_global_mouse_position())
	if Input.is_action_just_pressed("Inventory"):
		inventory.list_items()
	if Input.is_action_just_pressed("Player"):
		skills.list_skills()
	if Input.is_action_just_pressed("Map"):
		show_map = !show_map
		if show_map:
			_show_map()
		else:
			camera.zoom = current_zoom
			
func _show_map():
	var map_rect = map.tile_map.get_used_rect()
	var camera_rect = camera.get_viewport_rect()
	map_rect.position = map_rect.position * Vector2i(16, 16)
	map_rect.size = map_rect.size * Vector2i(16, 16)
	current_offset = camera.offset
	camera.zoom = map.tile_map.get_used_rect().size / camera.get_viewport().size
	var x_ratio = 1.0 * camera_rect.size.x / map_rect.size.x # The ratio of the width (The 1.0* is important to convert the ints to float so we get a float and not just 0)
	var y_ratio = 1.0 * camera_rect.size.y / map_rect.size.y # The ratio of the height
	if x_ratio < y_ratio:
		camera.zoom = Vector2(x_ratio, x_ratio)
	else:
		camera.zoom = Vector2(y_ratio, y_ratio)

func _physics_process(delta):
	camera.position = position
	if (show_map):
		_show_map()
	sprite.update_animation_state(navigation.current_id_path, navigation.target_pos)
	if navigation.current_id_path.is_empty():
		if action_node != null and !action_node.is_started():
			if navigation.get_tile_position().distance_to(action_node.navigation.get_tile_position()) <= 1:
				sprite.update_animation_direction(action_node.position)
				action_node.start()
			else:
				print("Can't reach!")
		return
	navigation.physics_process(delta)

func move_to_and_perform_action(node: Node2D):
	navigation.handle_move_to(node.position)
	action_node = node

func stop_actions():
	if action_node != null:
		action_node.stop()
		action_node = null

func complete_action(exp: Dictionary, result: Dictionary):
	skills.add_exp(exp)
	inventory.add_items(result);
