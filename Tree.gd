class_name ChoppableTree

extends Area2D

@export var hitpoints = 5
var alive = true

var time = 0
var regen_timer = 0
var TIME_PERIOD = 1
var player_is_doing_action = false
var EXP_PER_ACTION = {Woodcutting.NAME: 10.0}
var RESULT_PER_ACTION = {"log": 1}
var BASE_CHANCE_TO_FAIL_ACTION = 20.0

@onready var player: Player = $"../Player"
@onready var tile_map: TileMap = $"../TileMap"
@onready var sprite: Sprite2D = $"TreeSprite"
@onready var logSprite: Sprite2D = $"LogSprite"
@onready var animation_player: AnimationPlayer = $"AnimationPlayer"
@onready var progress_bar: ProgressBar = $"ProgressBar"
	
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.visible = true
	logSprite.visible = false
	player.grid.set_point_solid(tile_map.local_to_map(position), true)
	
func _mouse_enter():
	if alive:
		player.mouse_state.on_mouse_enter(self)
	
func _mouse_exit():
	player.mouse_state.on_mouse_exit(self)
	
func _input_event(viewport, event: InputEvent, shape_idx):
	if Input.is_action_just_pressed("LeftMouse"):
		if alive:
			player.move_to_and_perform_action(self)
		else:
			player.handle_move_to(self.position)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	time += delta
	regen_timer += delta

	if time > TIME_PERIOD:
		if player_is_doing_action:
			if hitpoints > 0:
				var chance = randf_range(0.0, 100.0)
				var fail_threshold = max(0.0, BASE_CHANCE_TO_FAIL_ACTION - player.skills.get_skill(Woodcutting.NAME).level)
				var crit_threshold = min(99.0 - (player.skills.get_skill(Woodcutting.NAME).level / 2), 99.0)
				print("Chance: " + str(chance) + ", Fail threshold: " + str(fail_threshold) + ", Crit threshold: " + str(crit_threshold))
				if chance <= fail_threshold:
					print("You miss your swing and the axe glances off the bark of the tree")
				else:
					if (chance >= crit_threshold):
						print("You perfectly sink your axe into the wood and do the work of two swings in one")
						hit(2, true)
					else:
						print("You successfully cut into the tree")
						hit(1)
		time = 0
		
	if regen_timer > TIME_PERIOD * 5:
		if !player_is_doing_action:
			if hitpoints < 5:
				hitpoints = hitpoints + 1
				progress_bar.value = hitpoints * (100 / 5)
		regen_timer = 0
	
	if hitpoints <= 0 && player_is_doing_action:
		print("Timber!")
		alive = false
		progress_bar.visible = true
		progress_bar.value = 0
		sprite.visible = false
		logSprite.visible = true
		player.mouse_state.on_mouse_exit(self)
		player.complete_action(EXP_PER_ACTION, RESULT_PER_ACTION)
		player.stop_actions()

	if hitpoints == 5 && !player_is_doing_action:
		alive = true
		progress_bar.visible = false
		sprite.visible = true
		logSprite.visible = false
			
func start():
	if alive:
		print("You begin chopping the tree")
		player_is_doing_action = true
	
func stop():
	animation_player.stop()
	player_is_doing_action = false
	
func is_started():
	return player_is_doing_action
	
func hit(damage: int, critical_hit = false):
	if (critical_hit):
		animation_player.play("shake_critical")
	else:
		animation_player.play("shake")
	hitpoints = hitpoints - damage

