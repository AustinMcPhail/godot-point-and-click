extends Resource
class_name PlayerInventory


@export_category("Equipment")
@export var head: EquipmentBase;
@export var neck: EquipmentBase;
@export var back: EquipmentBase;
@export var torso: EquipmentBase;
@export var legs: EquipmentBase;
@export var feet: EquipmentBase;
@export var main_hand: WeaponBase;
@export var off_hand: WeaponBase;
@export var main_hand_ring: EquipmentBase;
@export var off_hand_ring: EquipmentBase;
@export var main_hand_wrist: EquipmentBase;
@export var off_hand_wrist: EquipmentBase;

@export_category("Inventory")
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
