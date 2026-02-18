extends Node

@export var destuction_point : Marker2D
@onready var item_grid : Grid = $"../../%ItemGrid"

func _physics_process(_delta: float) -> void:
	var tile_pos = item_grid.worldToGrid(destuction_point.global_position)
	
	var item = item_grid.get_tile(tile_pos)
	
	if item:
		item_grid.set_tile(tile_pos,  null)
		await get_tree().create_timer(1).timeout
		item.queue_free()
