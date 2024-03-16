class_name ContextMenu

extends GridContainer

func _init():
	hide()
	
func _input(event):
	if Input.is_action_just_released("Escape"):
		hide()
		clear()

func add_item(label: String, callable: Callable):
	var button = Button.new()
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.text = label
	button.pressed.connect(
		func():
			clear()
			callable.call()
	)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_child(button)
	
func clear():
	hide()
	mouse_exited.emit()
	for n in get_children():
		remove_child(n)
		n.queue_free()
