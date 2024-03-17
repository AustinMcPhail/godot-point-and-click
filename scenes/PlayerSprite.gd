class_name PlayerSprite
extends Sprite2D

@onready var silhouette: Sprite2D = $"Silhouette"
@onready var animation_player: AnimationPlayer = $"AnimationPlayer"

var current_direction = "right"

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
	
func update_animation_direction(target_pos):
	var next_tile_is_left = target_pos && target_pos.x < get_parent().position.x
	var next_tile_is_right = target_pos && target_pos.x > get_parent().position.x
	
	if next_tile_is_left:
		current_direction = "left"
	elif next_tile_is_right:
		current_direction = "right"

func update_animation_state(current_id_path, target_pos):
	update_animation_direction(target_pos)
	
	if (current_id_path.is_empty() == false):
		animation_player.play("player/run_"+current_direction)
	else:
		animation_player.play("player/idle_"+current_direction)
		
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
