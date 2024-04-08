extends GridContainer

@onready var button_1: Button = $Button1
@onready var button_2: Button = $Button2
@onready var button_3: Button = $Button3
@onready var button_4: Button = $Button4
@onready var button_5: Button = $Button5
@onready var button_6: Button = $Button6
@onready var button_7: Button = $Button7
@onready var button_8: Button = $Button8
@onready var button_9: Button = $Button9
var player: Player

var buttons = []

var dragging_button
var hovered_button

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	buttons = [
		button_1,
		button_2,
		button_3,
		button_4,
		button_5,
		button_6,
		button_7,
		button_8,
		button_9
	]
	
	for button in buttons:
		button.mouse_entered.connect(button_entered.bind(button))
		button.mouse_exited.connect(button_exited.bind(button))
		button.button_down.connect(button_down.bind(button))
		button.button_up.connect(button_up.bind(button))

func _process(delta):
	if player != null:
		var inv_keys = player.inventory.items.keys()
		for i in range(inv_keys.size()):
			var button = get_button(i + 1)
			button.text = inv_keys[i]
		
func swap_buttons(a, b):
	var a_pos = a.position
	var b_pos = b.position
	a.position = b_pos
	b.position = a_pos
	print("swap: ", a, " <=> ", b)
	
		
func button_down(button):
	print("button_down")
	if hovered_button == button:
		dragging_button = button

func button_up(button):
	print("button_up")
	if dragging_button != null:
		if dragging_button == button:
			if dragging_button == hovered_button:
				dragging_button = null
			else:
				print("swap: ", button, " <=> ", hovered_button)
				swap_buttons(button, hovered_button)

func button_entered(button):
	hovered_button = button
	
func button_exited(button):
	if hovered_button == button:
		button = null

func get_button(pos: int) -> Button:
	if pos == 1:
		return button_1
	if pos == 2:
		return button_2
	if pos == 3:
		return button_3
	if pos == 4:
		return button_4
	if pos == 5:
		return button_5
	if pos == 6:
		return button_6
	if pos == 7:
		return button_7
	if pos == 8:
		return button_8
	if pos == 9:
		return button_9
	return
