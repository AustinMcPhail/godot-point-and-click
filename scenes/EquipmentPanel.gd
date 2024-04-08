extends PanelContainer

@onready var head_texture: TextureRect = $GridContainer/HBoxContainer/Head/TextureRect
@onready var neck_texture: TextureRect = $GridContainer/HBoxContainer2/Neck/TextureRect
@onready var back_texture: TextureRect = $GridContainer/HBoxContainer2/Back/TextureRect
@onready var main_hand_texture: TextureRect = $GridContainer/HBoxContainer3/MainHand/TextureRect
@onready var torso_texture: TextureRect = $GridContainer/HBoxContainer3/Torso/TextureRect
@onready var off_hand_texture: TextureRect = $GridContainer/HBoxContainer3/OffHand/TextureRect
@onready var legs_texture: TextureRect = $GridContainer/HBoxContainer4/Legs/TextureRect
@onready var feet_texture: TextureRect = $GridContainer/HBoxContainer5/Feet/TextureRect
@onready var main_hand_wrist_texture: TextureRect = $GridContainer/HBoxContainer6/MainHandWrist/TextureRect
@onready var main_hand_ring_texture: TextureRect = $GridContainer/HBoxContainer6/MainHandRing/TextureRect
@onready var off_hand_ring_texture: TextureRect = $GridContainer/HBoxContainer6/OffHandRing/TextureRect
@onready var off_hand_wrist_texture: TextureRect = $GridContainer/HBoxContainer6/OffHandWrist/TextureRect

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
		if player.inventory.head != null:
			head_texture.texture = player.inventory.head.texture
		if player.inventory.neck != null:
			neck_texture.texture = player.inventory.neck.texture
		if player.inventory.back != null:
			back_texture.texture = player.inventory.back.texture
		if player.inventory.torso != null:
			torso_texture.texture = player.inventory.torso.texture
		if player.inventory.main_hand != null:
			main_hand_texture.texture = player.inventory.main_hand.texture
		if player.inventory.off_hand != null:
			off_hand_texture.texture = player.inventory.off_hand.texture
		if player.inventory.legs != null:
			legs_texture.texture = player.inventory.legs.texture
		if player.inventory.feet != null:
			feet_texture.texture = player.inventory.feet.texture
		if player.inventory.main_hand_wrist != null:
			main_hand_wrist_texture.texture = player.inventory.main_hand_wrist.texture
		if player.inventory.main_hand_ring != null:
			main_hand_ring_texture.texture = player.inventory.main_hand_ring.texture
		if player.inventory.off_hand_wrist != null:
			off_hand_wrist_texture.texture = player.inventory.off_hand_wrist.texture
		if player.inventory.off_hand_wrist != null:
			off_hand_wrist_texture.texture = player.inventory.off_hand_wrist.texture
	pass
