class_name Grid extends Node2D

var tile_size = 128.0
var grid : Dictionary[Vector2i, Node2D]

func get_tile(tile_position : Variant, side : TilePart = TilePart.Center) -> Node2D:
	if tile_position is Vector2:
		tile_position = worldToGrid(tile_position)
	elif tile_position is Node2D:
		tile_position = worldToGrid(tile_position.global_position)
	elif tile_position is not Vector2i:
		push_error("Unknown Type for position in get_tile")
	return grid.get(_to_internal_position(tile_position, side))

func set_tile(tile_position : Vector2i, tile : Node2D, side : TilePart = TilePart.Center):
	var internal_position = _to_internal_position(tile_position, side)
	grid.set(internal_position, tile)
	
	if tile:
		tile.global_position = gridToWorld(tile_position, side)
		match side:
			TilePart.RightWall: tile.global_rotation_degrees = 0
			TilePart.UpperWall: tile.global_rotation_degrees = -90
			TilePart.LeftWall: tile.global_rotation_degrees = -180
			TilePart.LowerWall: tile.global_rotation_degrees = -270
		if tile.get_parent():
			tile.reparent(self)
		else:
			add_child(tile)

func gridToWorld(tile_position : Vector2i, tile_part : TilePart = TilePart.Center) -> Vector2:
	return _to_internal_position(tile_position, tile_part) * tile_size / 2

func worldToGrid(world_position : Vector2) -> Vector2i:
	return round(world_position / tile_size)

func worldToGridSide(world_position : Vector2) -> TilePart:
	return directionToTilePart(round(world_position * 2 / tile_size) as Vector2i - worldToGrid(world_position) * 2)

func _to_internal_position(tile_position : Vector2i, tile_part : TilePart) -> Vector2i:
	return tile_position * 2 + tilePartToDirection(tile_part)

func directionToTilePart(direction : Vector2i) -> TilePart:
	match direction.clampi(-1, 1):
		Vector2i(0, 0): return TilePart.Center
		Vector2i(0, -1): return TilePart.UpperWall
		Vector2i(0, 1): return TilePart.LowerWall
		Vector2i(1, 0): return TilePart.RightWall
		Vector2i(-1, 0): return TilePart.LeftWall
		Vector2i(-1, -1): return TilePart.UpperLeftCorner
		Vector2i(1, -1): return TilePart.UpperRightCorner
		Vector2i(-1, 1): return TilePart.LowerLeftCorner
		Vector2i(1, 1): return TilePart.LowerRightCorner
	return TilePart.Center

func tilePartToDirection(tile_part : TilePart) -> Vector2i:
	match tile_part:
		TilePart.Center: 			return Vector2i.ZERO
		TilePart.UpperWall: 		return Vector2i.UP
		TilePart.LowerWall: 		return Vector2i.DOWN
		TilePart.RightWall: 		return Vector2i.RIGHT
		TilePart.LeftWall: 			return Vector2i.LEFT
		TilePart.UpperLeftCorner: 	return Vector2i.UP + Vector2i.LEFT
		TilePart.UpperRightCorner: 	return Vector2i.UP + Vector2i.RIGHT
		TilePart.LowerLeftCorner: 	return Vector2i.DOWN + Vector2i.LEFT
		TilePart.LowerRightCorner: 	return Vector2i.DOWN + Vector2i.RIGHT
		_: push_error("Invalid tile part in request")
	return Vector2i.ZERO

enum TilePart{
	Center,
	UpperWall,
	LowerWall,
	RightWall,
	LeftWall,
	UpperLeftCorner,
	UpperRightCorner,
	LowerLeftCorner,
	LowerRightCorner
}
