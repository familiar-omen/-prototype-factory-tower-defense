extends Node

@export var spawn_point : Marker2D
@export var spawn_scene : PackedScene
@onready var item_grid : Grid = $"../../%ItemGrid"

func _physics_process(_delta: float) -> void:
	var tile_pos = item_grid.worldToGrid(spawn_point.global_position)
	
	if not item_grid.get_tile(tile_pos):
		item_grid.set_tile(tile_pos, spawn_scene.instantiate())
