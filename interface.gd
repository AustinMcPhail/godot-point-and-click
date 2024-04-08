extends CanvasLayer


@onready var inventory: Button = $Buttons/HBoxContainer/Inventory
@onready var proficiencies: Button = $Buttons/HBoxContainer/Proficiencies
@onready var rations: Button = $Buttons/HBoxContainer/Rations
@onready var equipment = $Buttons/HBoxContainer/Equipment

@onready var inventory_panel = $InventoryPanel
@onready var equipment_panel = $EquipmentPanel

func _ready():
	inventory.pressed.connect(inventory_pressed)
	equipment.pressed.connect(equipment_pressed)
	rations.pressed.connect(rations_pressed)
	proficiencies.pressed.connect(proficiencies_pressed)

func hide_all():
	inventory_panel.visible = false
	equipment_panel.visible = false
	pass

func inventory_pressed():
	var state = inventory_panel.visible
	hide_all()
	inventory_panel.visible = !state
	print("inventory clicked")
	
func equipment_pressed():
	var state = equipment_panel.visible
	hide_all()
	equipment_panel.visible = !state
	print("equipment clicked")
	
func rations_pressed():
	hide_all()
	print("rations clicked")
	
func proficiencies_pressed():
	hide_all()
	print("rations clicked")
