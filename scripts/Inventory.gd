class_name Inventory

extends Node

@export var items = {}
		
func add_items(_items: Dictionary):
	if (_items == null || _items.is_empty()):
		return
	
	for _item in _items.keys():
		if (items.has(_item)):
			items[_item] = items[_item] + _items[_item]
		else:
			if (items.keys().size() >= 9):
				print("Inventory full!")
			else:
				items[_item] = _items[_item]

func list_items():
	if (items.keys().is_empty()):
		print("Inventory is empty")
		return
	for item in items.keys():
		print(str(item) + " x " + str(items[item]))
