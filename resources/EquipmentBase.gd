extends ItemBase
class_name EquipmentBase
enum EquipmentSlots {
	HEAD,
	NECK,
	TORSO,
	LEGS,
	FEET,
	GLOVES,
	MAIN_HAND,
	OFF_HAND,
	MAIN_HAND_WRIST,
	OFF_HAND_WRIST,
	MAIN_HAND_RING,
	OFF_HAND_RING,
	ANOTHER_THING = -1
}
@export var equipment_slot: EquipmentSlots
@export var defense_bonus: int = 0
@export var attack_bonus: int = 0
@export var magic_bonus: int = 0
