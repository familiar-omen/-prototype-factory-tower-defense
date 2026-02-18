extends Node


@export var from_point : Marker2D
@export var to_point : Marker2D
@onready var item_grid : Grid = $"../../%ItemGrid"
@onready var foreground : Sprite2D = $"../Foreground"

var from_schedule : Scheduler.Schedule
var to_schedule : Scheduler.Schedule

var blocked_by
var block

var busy = false

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
	from_schedule.take_turn(self)
	
	var item = item_grid.get_tile(from_schedule.position)
	
	item_grid.set_tile(from_schedule.position, null)
	item_grid.set_tile(to_schedule.position, item)
	
	item.global_position = from_point.global_position
	
	var tween = create_tween()
	tween.bind_node(item)
	tween.tween_property(item, "global_position", to_point.global_position, 1)
	await tween.finished

func is_valid() -> bool:
	var turn = from_schedule.is_turn_of(self)
	var item = item_grid.get_tile(from_schedule.position)
	var space = not item_grid.get_tile(to_schedule.position)
	
	if not space: from_schedule.take_turn(self)
	
	var valid = item and space and turn
	
	var tween = create_tween()
	tween.bind_node(self)
	tween.tween_property(self, "foreground:self_modulate:a", 1.0 if valid else 0.2, 0.2)
	
	return valid

func request_put():
	to_schedule.requests.append(self)

	#
	#var scheduled = from_schedule.is_turn_of(self) and to_schedule.is_turn_of(self)
	#
	#foreground.self_modulate = Color(Color.WHITE, 1.0 if scheduled else 0.2)
	#
	#if busy:
		#return
	#elif not space:
		#from_schedule.take_turn(self)
	#elif not item:
		#to_schedule.take_turn(self)
	#elif scheduled:
		#item_grid.set_tile(from_schedule.position, null)
		#busy = true
		#var tween = create_tween()
		#tween.bind_node(item)
		#tween.tween_property(item, "global_position", to_point.global_position, 1)
		#tween.tween_callback(from_schedule.take_turn.bind(self))
		#tween.tween_callback(to_schedule.take_turn.bind(self))
		##tween.tween_callback(item_grid.set_tile.bind(from_schedule.position, null))
		#tween.tween_callback(item_grid.set_tile.bind(to_schedule.position, item))
		#await tween.finished
		#busy = false


#func _physics_process(_delta: float) -> void:
	#var item = item_grid.get_tile(from_schedule.position)
	##var space = not block or not block.is_blocking()
	#var space = not item_grid.get_tile(to_schedule.position)
	#
	#var scheduled = from_schedule.is_turn_of(self) and to_schedule.is_turn_of(self)
	#
	#foreground.self_modulate = Color(Color.WHITE, 1.0 if scheduled else 0.2)
	#
	#if busy:
		#return
	#elif not space:
		#from_schedule.take_turn(self)
	#elif not item:
		#to_schedule.take_turn(self)
	#elif scheduled:
		#item_grid.set_tile(from_schedule.position, null)
		#busy = true
		#var tween = create_tween()
		#tween.bind_node(item)
		#tween.tween_property(item, "global_position", to_point.global_position, 1)
		#tween.tween_callback(from_schedule.take_turn.bind(self))
		#tween.tween_callback(to_schedule.take_turn.bind(self))
		##tween.tween_callback(item_grid.set_tile.bind(from_schedule.position, null))
		#tween.tween_callback(item_grid.set_tile.bind(to_schedule.position, item))
		#await tween.finished
		#busy = false
	
	
	#scheduled = from_schedule.is_turn_of(self) and to_schedule.is_turn_of(self)
	
		
	#foreground.self_modulate = Color(foreground.self_modulate, 255 if scheduled else 50)
		
