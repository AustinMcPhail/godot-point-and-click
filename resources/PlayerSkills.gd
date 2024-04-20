extends Resource
class_name PlayerSkills

var exp_mod = 1

@export_category("Woodcutting")
var woodcutting: Skill = Skill.new("woodcutting")
@export_range(0, 100) var woodcutting_level: int = woodcutting.level:
	set(level):
		woodcutting.set_level(level)
	get:
		return woodcutting.level
		
@export_category("Accuracy")
var accuracy: Skill = Skill.new("Accuracy")
@export_range(0, 100) var accuracy_level: int = accuracy.level:
	set(level):
		accuracy.set_level(level)
	get:
		return accuracy.level
		
		
func add_exp(exp: Dictionary):
	if (exp == null || exp.is_empty()):
		return
	for _skill in exp.keys():
		print(_skill.capitalize() + " +" + str(_modified_exp(exp[_skill])) + "exp")		
		if (_skill == woodcutting.NAME):
			woodcutting.add_exp(_modified_exp(exp[_skill]))

func list_skills():
	print("Exp Modifier: x" + str(exp_mod))
	print(woodcutting.get_exp_str())
		
func set_exp_mod(mod):
	exp_mod = mod

func get_skill(skill) -> Skill:
	if (skill == woodcutting.NAME):
		return woodcutting
	return null

func _modified_exp(exp: float) -> float:
	return exp * exp_mod
