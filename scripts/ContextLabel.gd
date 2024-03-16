class_name ContextLabel

extends PanelContainer

@onready var label: Label = $"Label"

var text = "":
	set(value):
		label.text = value
	get:
		return label.text

func _ready():
	visible = false

func _process(delta):
	position = Vector2(
		get_parent().get_global_mouse_position().x + 15,
		get_parent().get_global_mouse_position().y - 15
	)
	pass
