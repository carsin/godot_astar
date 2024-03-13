extends Node2D

@onready var map_grid = $"../TileMap"
@onready var target = $"../Target"

var astar_grid: AStarGrid2D
var player_path: Array[Vector2i]
var moving = false
var target_pos: Vector2
var winsize
var bounds_x
var bounds_y

func _ready():
	_init_grid()
	_update_grid_from_tilemap()
	_randomize_target_pos()
	target_pos = map_grid.local_to_map(target.global_position)
	player_path = astar_grid.get_id_path(map_grid.local_to_map(global_position), target_pos)
	print("made path: ", position, " to ", target_pos)

func _randomize_target_pos() -> void:
	winsize = get_viewport().get_visible_rect().size
	var foundTarget = false
	var target_x = 0
	var target_y = 0
	var id: Vector2i
	while (!foundTarget):
		target_x = randi_range(1, astar_grid.size.x - 1) * astar_grid.cell_size.x
		target_y = randi_range(1, astar_grid.size.y - 1) * astar_grid.cell_size.y
		id = Vector2i(target_x / astar_grid.cell_size.x, target_y / astar_grid.cell_size.y)
		print("checking if wall at ", id)
		if map_grid.get_cell_source_id(0, id) >= 0:
			var is_wall = map_grid.get_cell_tile_data(0, id).get_custom_data('wall')
			foundTarget = !is_wall
			print("wall: ", is_wall)
	
	target.global_position.x = target_x
	target.global_position.y = target_y

func _physics_process(delta):
	if player_path.is_empty():
		return
	
	if !moving:
		target_pos = map_grid.map_to_local(player_path.front())
		moving = true
		
	global_position = global_position.move_toward(target_pos, 10)
	
	if global_position == target_pos:
		player_path.pop_front()
		
		if player_path.is_empty() == false:
			target_pos = map_grid.map_to_local(player_path.front())
		else:
			moving = false
		
func _init_grid() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.size = map_grid.get_used_rect().size
	astar_grid.cell_size = map_grid.tile_set.tile_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar_grid.jumping_enabled = false
	astar_grid.update()

func _update_grid_from_tilemap() -> void:
	for i in range(astar_grid.size.x):
		for j in range(astar_grid.size.y):
			var id = Vector2i(i, j)
			if map_grid.get_cell_source_id(0, id) >= 0:
				var is_wall = map_grid.get_cell_tile_data(0, id).get_custom_data('wall')
				astar_grid.set_point_solid(Vector2i(i, j), is_wall)
			else:
				astar_grid.set_point_solid(Vector2i(i, j), true)
