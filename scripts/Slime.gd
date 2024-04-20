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
@onready var sprite_2d = $Sprite2D
@onready var pointer

func _ready():
	player_speech = get_tree().get_first_node_in_group("player_speech")
	player = get_tree().get_first_node_in_group("player")
	map = get_tree().get_first_node_in_group("map")
	pointer = get_tree().get_first_node_in_group("pointer")
	navigation = Navigation.new(map, self)
	navigation.set_solid(true)
	navigation.set_speed(stats.movement_speed)
	navigation.show_path = true
	spawn_tile = navigation.get_tile_position()
	health_bar.max_value = stats.max_hitpoints
	health_bar.value = stats.max_hitpoints
	if stats.sprite != null:
		sprite_2d.texture = stats.sprite
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
				attack()
			else:
				player.navigation.handle_move_to(self.position)
				
func _process(delta):
	health_bar.max_value = stats.max_hitpoints
	health_bar.value = stats.current_hitpoints

func _physics_process(delta):
	if threat == null && navigation.current_id_path.is_empty():
		wander_timer = wander_timer + delta
		if wander_timer > TIME_PERIOD * 2:
			navigation.handle_move_to(find_new_target_pos(
				spawn_tile,
				stats.wander_range
			))
			wander_timer = 0
	elif threat != null:
		var distance_from_player = Vector2.ZERO.distance_to(threat.position - position)
		var line_of_sight_in_tiles = stats.line_of_sight * 16
		if distance_from_player <= line_of_sight_in_tiles:
			navigation.handle_move_to(
				threat.position,
				1
			)
			if navigation.get_tile_position().distance_to(threat.navigation.get_tile_position()) != 1:
				navigation.handle_move_to(find_adjacent_target_pos(
					threat.navigation.get_tile_position()
				))
		else:
			navigation.handle_move_to(find_new_target_pos(
				spawn_tile,
				stats.wander_range
			))
			threat = null
	if !navigation.current_id_path.is_empty():
		navigation.physics_process(delta)
	queue_redraw()

func _mouse_enter():
	pointer.set_hovered(self)

func _mouse_exit():
	pointer.clear_hovered(self)
	
func _draw():
	navigation.draw()
	if threat != null:
		draw_line(
			Vector2.ZERO,
			threat.position - position,
			Color.CYAN
		)

func find_new_target_pos(
	origin_tile: Vector2,
	wander_range: int
):
	var rand_x = randi_range(origin_tile.x - wander_range, origin_tile.x + wander_range)
	var rand_y = randi_range(origin_tile.y - wander_range, origin_tile.y + wander_range)
	var pos = Vector2(rand_x, rand_y)
	return map.tile_map.map_to_local(pos)
	
func find_adjacent_target_pos(
	origin_tile: Vector2
):
	var left = Vector2i(origin_tile.x - 1, origin_tile.y)
	var right = Vector2i(origin_tile.x + 1, origin_tile.y)
	var up = Vector2i(origin_tile.x, origin_tile.y + 1)
	var down = Vector2i(origin_tile.x, origin_tile.y - 1)
	
	var pos = left;
	var closest: float = INF
	var same_distance = []
	
	if navigation.get_tile_position().distance_to(left) <= closest:
		if !navigation.map.grid.is_point_solid(left):
			closest = navigation.get_tile_position().distance_to(left)
			pos = left
	if navigation.get_tile_position().distance_to(right) <= closest:
		if !navigation.map.grid.is_point_solid(right):
			closest = navigation.get_tile_position().distance_to(right)
			pos = right
	if navigation.get_tile_position().distance_to(up) <= closest:
		if !navigation.map.grid.is_point_solid(up):
			closest = navigation.get_tile_position().distance_to(up)
			pos = up
	if navigation.get_tile_position().distance_to(down) <= closest:
		if !navigation.map.grid.is_point_solid(down):
			closest = navigation.get_tile_position().distance_to(down)
			pos = down

	return map.tile_map.map_to_local(pos)

func something_enter_threat_area(body: PhysicsBody2D):
	if body == player:
		threat = player
		print("player entered threat area")
	
func something_exit_threat_area(body: PhysicsBody2D):
	if body == player:
		print("player exited threat area")
	
func get_context_label():
	return stats.display_name
	
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
	stats.current_hitpoints = stats.current_hitpoints - damage

func attack():
	player.queue_action(self, Player.ActionType.ATTACK)
	
func on_attack(skills: PlayerSkills):
	if stats.current_hitpoints > 0:
		var chance = randf_range(0.0, 100.0)
		var fail_threshold = max(0.0, stats.defense_level - skills.accuracy.level)
		var crit_threshold = min(99.0 - (skills.accuracy.level / 2), 99.0)
		print("Chance: " + str(chance) + ", Fail threshold: " + str(fail_threshold) + ", Crit threshold: " + str(crit_threshold))
		if chance <= fail_threshold:
			print("You miss your attack on the ", stats.display_name)
		else:
			if (chance >= crit_threshold):
				print("You perfectly strike the ", stats.display_name)
				hit(2, true)
			else:
				print("You strike the ", stats.display_name)
				hit(1)

func get_context_menu():
	return [
		["Attack", self.attack],
		["Examine", self.examine]
	]
