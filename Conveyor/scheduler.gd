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
		#if schedule.is_end:
			#schedule.do_tick()
	
	
	pass
	#for schedule in schdules.values():
		#schedule.do_requests()

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
	
	var next_inserter : int = 0
	var inserter_list : Array = []
	var next_extractor : int = 0
	var extractor_list : Array = []
	
	var triggers = 0:
		set(value):
			triggers = value
			if triggers > extractor_list.size():
				do_tick()
				triggers = 0
	
	func _init(position):
		self.position = position
	
	var is_end:
		get: return not extractor_list
	
	func do_tick():
		if inserter_list:
			var count = inserter_list.size()
			var found = null
			next_inserter %= count
			for i in range(next_inserter, next_inserter + count):
				if inserter_list[i % count].is_valid():
					if not found:
						found = inserter_list[i % count]
						found.do_tick()
						next_inserter = i
						inserter_list[i % count].from_schedule.triggers += 1
				else:
					inserter_list[i % count].from_schedule.triggers += 1
			
			next_inserter += 1
	
	
	#func do_requests():
		#if inserter_list:
			#next_inserter %= inserter_list.size()
			#inserter_list[next_inserter].is_valid()
			#next_extractor += 1
	#
	#func open_insertion():
		#var count = inserter_list.size()
		#next_inserter %= count
		#
		#for i in range(next_inserter, next_inserter + count):
			#if inserter_list[next_inserter % count].is_valid():
				#break
		#
		#next_extractor += 1
	
	
	
	
		#
		#if extractor_list:
			#next_extractor %= extractor_list.size()
			#extractor_list[next_extractor].request_put()
			#next_extractor += 1
	#
	#func
	
	func is_turn_of(node) -> bool:
		if not extractor_list.size(): return false
		next_extractor %= extractor_list.size()
		return extractor_list[next_extractor] == node
	
	func take_turn(node):
		if extractor_list.size():
			next_extractor %= extractor_list.size()
			if extractor_list[next_extractor] == node:
				next_extractor += 1
