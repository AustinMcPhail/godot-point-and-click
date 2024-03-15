class_name Map

extends TileMap

var grid: AStarGrid2D

func _init():
	add_to_group("map")

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = AStarGrid2D.new()
	grid.region = get_used_rect()
	grid.cell_size = Vector2(16, 16)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
