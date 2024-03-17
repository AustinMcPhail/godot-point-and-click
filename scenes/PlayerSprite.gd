class_name PlayerSprite
extends Sprite2D

@onready var silhouette: Sprite2D = $"Silhouette"

# Called when the node enters the scene tree for the first time.
func _ready():
	silhouette.texture = texture
	silhouette.offset = offset
	silhouette.flip_h = flip_h
	silhouette.hframes = hframes
	silhouette.vframes = vframes
	silhouette.frame = frame
	silhouette.region_enabled = region_enabled
	silhouette.region_rect = region_rect

func update_animation_state(current_id_path):
	if (current_id_path.is_empty() == false):
		pass
		#play("move")
	else:
		pass
		#play("default")

func update_player_direction(current_id_path, target_pos):
	if current_id_path.is_empty() == false && target_pos.x < position.x:
		pass
		#flip_h = true
	elif current_id_path.is_empty() == false && target_pos.x > position.x:
		#flip_h = false
		pass
		
func _set(property, value) -> bool:
	if is_instance_valid(silhouette):
		match property:
			"texture":
				silhouette.texture = value
			"offset":
				silhouette.offset = value
			"flip_h":
				silhouette.flip_h = value
			"hframes":
				silhouette.hframes = value
			"vframes":
				silhouette.vframes = value
			"frame":
				silhouette.frame = value
	return false
