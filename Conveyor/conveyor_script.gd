class_name ConveyorLogic extends Node

@export var from_point : Marker2D
@export var to_point : Marker2D

@onready var item_grid : Grid = $"../../%ItemGrid"
@onready var foreground : Sprite2D = $"../Foreground"

var from_schedule : Scheduler.Schedule
var to_schedule : Scheduler.Schedule

func _ready() -> void:
	var from_pos = item_grid.worldToGrid(from_point.global_position)
	var to_pos = item_grid.worldToGrid(to_point.global_position)
	
	from_schedule = Scheduler.extractions(from_pos)
	to_schedule = Scheduler.insertions(to_pos)
	
	Scheduler.register_extraction(from_pos, self)
	Scheduler.register_insertion(to_pos, self)

func _exit_tree() -> void:
	var from_pos = item_grid.worldToGrid(from_point.global_position)
	var to_pos = item_grid.worldToGrid(to_point.global_position)
	
	Scheduler.deregister_extraction(from_pos, self)
	Scheduler.deregister_insertion(to_pos, self)

func do_tick():
	var item = item_grid.get_tile(from_schedule.position)
	
	item_grid.set_tile(from_schedule.position, null)
	item_grid.set_tile(to_schedule.position, item)
	item.global_position = from_point.global_position
	
	var tween = create_tween()
	tween.bind_node(item)
	tween.tween_property(item, "global_position", to_point.global_position, 1)

func is_valid() -> bool:
	var turn = from_schedule.is_turn_of(self)
	var item = item_grid.get_tile(from_schedule.position)
	var space = not item_grid.get_tile(to_schedule.position)
	
	var valid = item and space and turn
	
	var tween = create_tween()
	tween.bind_node(self)
	tween.tween_property(self, "foreground:self_modulate:a", 1.0 if valid else 0.2, 0.2)
	
	return valid
