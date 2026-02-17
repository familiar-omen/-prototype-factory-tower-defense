extends Node

@onready
var structure_grid : Grid = %StructureGrid

@export
var spawner : PackedScene
@export
var destroyer : PackedScene
@export
var conveyor : PackedScene

var last_pos : Vector2i

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pos := structure_grid.worldToGrid( get_viewport().get_camera_2d().get_global_mouse_position())
		var part := structure_grid.directionToTilePart(pos - last_pos)
		
		if pos != last_pos:
			if Input.is_action_pressed("place_conveyor"):
				var prev = structure_grid.get_tile(last_pos, part)
				if prev: prev.queue_free()
				structure_grid.set_tile(last_pos, conveyor.instantiate(), part)
			if Input.is_action_pressed("delete_conveyor"):
				var prev = structure_grid.get_tile(last_pos, part)
				if prev: prev.queue_free()
				structure_grid.set_tile(last_pos, null, part)
		
		last_pos = pos

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("place_spawner"):
		var pos := structure_grid.worldToGrid( get_viewport().get_camera_2d().get_global_mouse_position())
		structure_grid.set_tile(pos, spawner.instantiate(), Grid.TilePart.Center)
	
	if Input.is_action_just_pressed("place_destroyer"):
		var pos := structure_grid.worldToGrid( get_viewport().get_camera_2d().get_global_mouse_position())
		structure_grid.set_tile(pos, destroyer.instantiate(), Grid.TilePart.Center)
