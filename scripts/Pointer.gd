class_name Pointer

extends Node2D

var can_interact = false
var last_hover
var hovered = null

@onready var label: ContextLabel = $"ContextLabel"
@onready var menu: ContextMenu = $"ContextMenu"

var context_menu_entered: Signal
var context_menu_exited: Signal
var map: Map

func _ready():
	map = get_tree().get_first_node_in_group("map")
	context_menu_entered = menu.mouse_entered
	context_menu_exited = menu.mouse_exited

func _input(event):
	if Input.is_action_just_pressed("RightMouse") && !hovered && menu.visible:
		close_context_menu()

func set_hovered(node):
	if hovered == node:
		return
	hovered = node
	if hovered != null && hovered.get_context_label:
		label.text = hovered.get_context_label()
		label.show()

func clear_hovered(node):
	if hovered != node:
		return
	hovered = null
	label.text = ""
	label.hide()
	
func open_context_menu(node, position):
	menu.clear()
	menu.position = position;
	for menu_item in node.get_context_menu():
		menu.add_item(menu_item[0], menu_item[1])
	menu.show()

func close_context_menu():
	menu.clear()
	menu.hide()

func _process(delta):
	if label.text != "":
		label.show()
	else:
		label.hide()
	if hovered != null && hovered.cursor:
		Input.set_default_cursor_shape(hovered.cursor)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
