class_name MouseState

extends Node

var can_interact = false
var last_hover

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
