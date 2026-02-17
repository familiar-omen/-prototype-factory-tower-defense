extends Node

var insertion_schdule : Dictionary[Vector2i, Schedule]
var extraction_schdule : Dictionary[Vector2i, Schedule]

class Schedule:
	var next : int = 0
	var list : Array = []
	
	func is_turn_of(node) -> bool:
		if not list.size(): return false
		next %= list.size()
		return list[next] == node
	
	func take_turn(node):
		if list.size():
			next %= list.size()
			if list[next] == node:
				next += 1
