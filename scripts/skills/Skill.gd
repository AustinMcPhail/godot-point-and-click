class_name Skill

extends Object

var EXP_FOR_FIRST_LEVEL = get_exp_required_for_level(2)
var name
@export var current_exp = 0.0
var exp_until_next_level = EXP_FOR_FIRST_LEVEL
@export var level = 1
var max_level = 100

func _init(_name):
	name = _name

func add_exp(exp: float):
	if (exp == null):
		return
	current_exp = current_exp + exp
	exp_until_next_level = exp_until_next_level - exp
	if (exp_until_next_level <= 0):
		while exp_until_next_level <= 0:
			level = level + 1
			exp_until_next_level = get_exp_required_for_level(level + 1) - abs(exp_until_next_level)

func get_exp_str():
	return name + "[" + str(level) + "]: current=" + str(current_exp) +"exp, next=" + str(exp_until_next_level) + "exp" 

func set_level(_level: int):
	print("Setting to level: " + str(_level))
	level = _level
	current_exp = get_exp_required_for_level(level)
	exp_until_next_level = get_exp_required_for_level(level + 1)
	print("current_exp " + str(current_exp))
	print("exp_until_next_level " + str(exp_until_next_level))
	
func set_exp(_exp: int):
	current_exp = _exp
	level = get_level_from_exp(_exp)
	print("Setting to level: " + str(level))
	print("current_exp " + str(current_exp))
	exp_until_next_level = get_exp_required_for_level(level + 1)
	print("exp_until_next_level " + str(exp_until_next_level))

func get_exp_required_for_level(level: int):
	var points = 0
	var total = 0
	for l in range(1, level):
		points = points + floor(l + 300.0 * pow(2.0, l / 7.0))
		if l >= level:
			return total
		total = int(floor(points / 4));
	return total
	
func get_level_from_exp(_exp: int) -> int:
	var level = 1
	while true && level <= 100:
		var exp_required = get_exp_required_for_level(level)
		if _exp < exp_required:
			return level - 1
		level += 1
	return 100
