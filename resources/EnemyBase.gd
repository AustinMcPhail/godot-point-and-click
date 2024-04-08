extends NPCBase
class_name EnemyBase

@export_category("Stats")
@export var challenge_level = 1
@export var defense_level = 1
@export var attack_level = 1
@export var attack_speed = 1
@export var movement_speed = 1

@export_category("Player Detection")
@export var wander_range = 1
@export var line_of_sight = 10
@export var threat_area_size = 2

@export_category("Animation")
@export var move_left: String = ""
@export var move_right: String = ""
@export var move_up: String = ""
@export var move_down: String = ""
@export var attack: String = ""
@export var idle: String = ""
