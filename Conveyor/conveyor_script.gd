extends Node

@export var from_point : Marker2D
@export var to_point : Marker2D
@onready var item_grid : Grid = $"../../%ItemGrid"
@onready var foreground : Sprite2D = $"../Foreground"

var from_schedule : Scheduler.Schedule
var to_schedule : Scheduler.Schedule

var busy = false

func _ready() -> void:
	var from_pos = item_grid.worldToGrid(from_point.global_position)
	var to_pos = item_grid.worldToGrid(to_point.global_position)
	
	from_schedule = Scheduler.extraction_schdule.get_or_add(from_pos, Scheduler.Schedule.new())
	to_schedule = Scheduler.insertion_schdule.get_or_add(to_pos, Scheduler.Schedule.new())
	
	from_schedule.list.append(self)
	to_schedule.list.append(self)

func _exit_tree() -> void:
	from_schedule.list.erase(self)
	to_schedule.list.erase(self)

func _physics_process(_delta: float) -> void:
	var from_pos = item_grid.worldToGrid(from_point.global_position)
	var to_pos = item_grid.worldToGrid(to_point.global_position)
	
	var item = item_grid.get_tile(from_pos)
	var space = not item_grid.get_tile(to_pos)
	
	var scheduled = from_schedule.is_turn_of(self) and to_schedule.is_turn_of(self)
	
	foreground.self_modulate = Color(Color.WHITE, 1.0 if scheduled else 0.2)
	
	if busy:
		return
	elif not space:
		from_schedule.take_turn(self)
	elif not item:
		to_schedule.take_turn(self)
	elif scheduled:
		item_grid.set_tile(from_pos, null)
		busy = true
		var tween = create_tween()
		tween.bind_node(item)
		tween.tween_callback(from_schedule.take_turn.bind(self))
		tween.tween_property(item, "global_position", to_point.global_position, 1)
		tween.tween_callback(to_schedule.take_turn.bind(self))
		tween.tween_callback(item_grid.set_tile.bind(to_pos, item))
		await tween.finished
		busy = false
	
	
	#scheduled = from_schedule.is_turn_of(self) and to_schedule.is_turn_of(self)
	
		
	#foreground.self_modulate = Color(foreground.self_modulate, 255 if scheduled else 50)
		
