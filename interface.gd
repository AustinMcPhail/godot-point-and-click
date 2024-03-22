extends CanvasLayer


@onready var inventory: Button = $Buttons/HBoxContainer/Inventory
@onready var proficiencies: Button = $Buttons/HBoxContainer/Proficiencies
@onready var rations: Button = $Buttons/HBoxContainer/Rations

@onready var inventory_panel = $InventoryPanel

func _ready():
	inventory.pressed.connect(inventory_pressed)
	rations.pressed.connect(rations_pressed)
	proficiencies.pressed.connect(proficiencies_pressed)
	
	
func inventory_pressed():
	inventory_panel.visible = !inventory_panel.visible
	print("inventory clicked")
	
func rations_pressed():
	print("rations clicked")
	
func proficiencies_pressed():
	print("rations clicked")
