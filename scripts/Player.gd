extends CharacterBody2D
class_name Player

enum ActionType {
	ATTACK,
	CHOP
}

@export_category("Admin")
@export var skills: PlayerSkills
@export var inventory: PlayerInventory
@export var show_map : bool = false

@onready var sprite: PlayerSprite = $"PlayerSprite"
@onready var main_hand: TextureRect = $MainHand

var action_cooldown_timer = 0

var camera: Camera2D
var pointer: Pointer
var current_zoom = Vector2(8, 8)
var current_offset: Vector2
var map: Map
var navigation: Navigation
var attack_timer

var current_action
var action_queue = []

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_tree().get_first_node_in_group("camera")
	pointer = get_tree().get_first_node_in_group("pointer")
	map = get_tree().get_first_node_in_group("map")
	navigation = Navigation.new(map, self)
	navigation.set_speed(1.5)
	navigation.set_solid(true)
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
		action_queue.clear()
		current_action = null
		pointer.close_context_menu()
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
	do_current_action(delta)
	sprite.update_animation_state(navigation.current_id_path, navigation.target_pos)
	navigation.physics_process(delta)

func queue_action(node: Node2D, type: ActionType):
	action_queue.push_back([node, type])

func complete_action(exp: Dictionary, result: Dictionary):
	skills.add_exp(exp)
	inventory.add_items(result);
	
func do_current_action(delta):
	action_cooldown_timer -= delta
	
	if current_action == null && !action_queue.is_empty():
		current_action = action_queue.pop_front()
	
	if current_action != null:
		var node = current_action[0]
		var action_type: ActionType = current_action[1]
		var path: Array = navigation.get_path_to(node.position, 1)[0]
		if !path.is_empty():
			navigation.handle_move_to(node.position, 1)
		else:
			if action_type == ActionType.ATTACK:
				attack(node, delta)

var attack_cooldown = 5
func attack(node, delta):
	if action_cooldown_timer <= 0:
		print(Time.get_unix_time_from_system(), " Attacking")
		node.on_attack(skills)
		action_cooldown_timer = attack_cooldown
	pass
