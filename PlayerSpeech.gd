extends PanelContainer

@onready var label = $Label
var player: Player

var time = 0
var TIME_PERIOD = 10

func _ready():
	player = get_tree().get_first_node_in_group("player")
	visible = false
	label.text = ""

func _process(delta):
	if visible == true:
		time += delta
		if time >= TIME_PERIOD / 3:
			modulate.a = 1 - ((time / (TIME_PERIOD / 3)) - 1)
			if time >= TIME_PERIOD:
				time = 0
				visible = false
				label.text = ""

func say(str):
	time = 0
	modulate.a = 1
	visible = true
	label.text = str
