class_name ContextMenu

extends PopupMenu

func _input(event):
	if visible && Input.is_action_just_pressed("RightMouse"):
		position = get_parent().get_viewport().get_mouse_position()
		clear()
		add_item("Examine")
