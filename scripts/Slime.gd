extends CharacterBody2D

@export var stats: EnemyBase
@export var can_wander: bool = false

var map: Map
var player_speech
var player: Player
var previous_pos: Vector2 = Vector2.ZERO
var spawn_tile: Vector2 = Vector2.ZERO

var navigation: Navigation

var time = 0
var wander_timer = 0
var TIME_PERIOD = 1

var cursor = Input.CURSOR_POINTING_HAND

var threat: Player
var alive = true
var player_is_doing_action = false

@onready var threat_area: Area2D = $"ThreatArea"
@onready var threat_area_shape: CollisionShape2D = $"ThreatArea/CollisionShape2D"
@onready var health_bar: TextureProgressBar = $"TextureProgressBar"
@onready var pointer

func _ready():
	player_speech = get_tree().get_first_node_in_group("player_speech")
	player = get_tree().get_first_node_in_group("player")
	map = get_tree().get_first_node_in_group("map")
	pointer = get_tree().get_first_node_in_group("pointer")
	navigation = Navigation.new(map, self)
	navigation.set_speed(0.5)
	spawn_tile = navigation.get_tile_position()
	health_bar.max_value = stats.max_hitpoints
	health_bar.value = stats.max_hitpoints
	threat_area_shape.shape.size = Vector2(
		16 * stats.threat_area_size, 
		16 * stats.threat_area_size
	)
	threat_area.body_entered.connect(something_enter_threat_area)
	threat_area.body_exited.connect(something_exit_threat_area)

func _input_event(viewport, event: InputEvent, shape_idx):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("RightMouse"):
			pointer.open_context_menu(self, event.global_position)
		if Input.is_action_just_pressed("LeftMouse"):
			if alive:
				player.move_to_and_perform_action(self)
			else:
				player.handle_move_to(self.position)

func _physics_process(delta):	
	if threat == null && navigation.current_id_path.is_empty():
		wander_timer = wander_timer + delta
		if wander_timer > TIME_PERIOD * 2:
			find_new_target_pos()
			wander_timer = 0
	elif threat != null:
		var distance_from_player = Vector2.ZERO.distance_to(threat.position - position)
		var line_of_sight_in_tiles = stats.line_of_sight * 16
		if distance_from_player <= line_of_sight_in_tiles:
			navigation.handle_move_to(threat.position)
			#navigation.current_id_path.pop_back()
		else:
			find_new_target_pos()
			threat = null

	if threat != null:
		if navigation.get_tile_position() == threat.navigation.get_tile_position():
			navigation.handle_move_to(previous_pos)

	if !navigation.current_id_path.is_empty():
		navigation._physics_process(delta)
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
	var rand_x = randi_range(spawn_tile.x - stats.wander_range, spawn_tile.x + stats.wander_range)
	var rand_y = randi_range(spawn_tile.y - stats.wander_range, spawn_tile.y + stats.wander_range)
	var pos = Vector2(rand_x, rand_y)
	navigation.handle_move_to(map.tile_map.map_to_local(pos))
	
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
	
func start():
	if alive:
		print("You begin attacking the slime")
		player_is_doing_action = true
	
func stop():
	#animation_player.stop()
	player_is_doing_action = false
	
func is_started():
	return player_is_doing_action
	
func hit(damage: int, critical_hit = false):
	#if (critical_hit):
		#animation_player.play("shake_critical")
	#else:
		#animation_player.play("shake")
	stats.hitpoints = stats.hitpoints - damage

func attack():
	player.move_to_and_perform_action(self)

func get_context_menu():
	return [
		["Attack", self.attack],
		["Examine", self.examine]
	]
