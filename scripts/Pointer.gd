class_name Pointer

extends Node2D

var can_interact = false
var last_hover

@onready var menu: ContextMenu = $"PopupMenu"

func _input(event):
	if Input.is_action_just_pressed("RightMouse"):
		menu.visible = true
		menu.position = get_viewport().get_mouse_position()
		menu.clear()
		menu.add_item("Examine")
	else:
		if menu != null:
			menu.visible = false

func set_can_interact(canInteract: bool):
	can_interact = canInteract
	
func on_mouse_enter(node):
	last_hover = node
	can_interact = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
func on_mouse_exit(node):
	if last_hover == node:
		can_interact = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
