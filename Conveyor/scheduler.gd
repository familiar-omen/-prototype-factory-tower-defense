extends Node

static var conveyor_tick : Tween

var schdules : Dictionary[Vector2i, Schedule]

func _init():
	if not conveyor_tick:
		conveyor_tick = create_tween()
		conveyor_tick.set_loops()
		conveyor_tick.tween_interval(1)
	conveyor_tick.loop_finished.connect(do_tick.unbind(1))

func do_tick():
	for schedule in schdules.values():
		schedule.triggers = 1

func extractions(position) -> Schedule:
	return Scheduler.schdules.get_or_add(position, Scheduler.Schedule.new(position))

func insertions(position) -> Schedule:
	return Scheduler.schdules.get_or_add(position, Scheduler.Schedule.new(position))

func register_extraction(position, node):
	extractions(position).extractor_list.append(node)
	#recalculate_blocks(node.to_schedule.position)

func register_insertion(position, node):
	insertions(position).inserter_list.append(node)
	#recalculate_blocks(node.to_schedule.position)

func deregister_extraction(position, node):
	extractions(position).extractor_list.erase(node)
	#recalculate_blocks(node.to_schedule.position)

func deregister_insertion(position, node):
	insertions(position).inserter_list.erase(node)
	#recalculate_blocks(node.to_schedule.position)

func recalculate_blocks(position):
	var insertion = insertions(position)
	var extraction = extractions(position)
	
	var can_block = insertion.list.size() > extraction.list.size()
	
	if not can_block: return
	
	for inserter in insertion.list:
		var blocker = Blocker.new()
		blocker.origin = inserter.item_grid.worldToGrid(inserter.to_point.global_position)
		blocker.grid = inserter.item_grid
		
		while inserter:
			inserter.block = blocker
			var inputs = insertions(inserter.from_schedule.position).list
			
			for s in inputs:
				if s.block == blocker:
					blocker.blocking = false
			
			if inputs.size() == 1:
				inserter = inputs[0]
			else:
				inserter = null

class Blocker:
	var blocking = true
	var origin
	var grid
	
	func is_blocking():
		return blocking and grid.get_tile(origin)

class Schedule:
	var position : Vector2i
	
	var next : int = 0
	var offset : int = 0
	var inserter_list : Array = []
	var extractor_list : Array = []
	
	var triggers = 0:
		set(value):
			triggers = value
			if triggers > extractor_list.size():
				do_tick()
				triggers = -1000
	
	func _init(position):
		self.position = position
	
	func do_tick():
		#if inserter_list.size() == 2:
			#print(next)
		if inserter_list:
			var count = inserter_list.size()
			var found = null
			for i in range(next, next + count):
				var cur = inserter_list[i % count]
				if cur.is_valid():
					if not found:
						found = cur
						found.do_tick()
						found.from_schedule.triggers += 1
						#next = i
				else:
					cur.from_schedule.triggers += 1
			if found:
				next += 1
	
	
	
	func is_turn_of(node) -> bool:
		if not extractor_list: return false
		return extractor_list[(next + offset) % extractor_list.size()] == node
	
	#func take_turn(node):
		#if extractor_list:
			#if extractor_list[(next + offset) % extractor_list.size()] == node:
				#next += 1
				
