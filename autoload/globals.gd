extends Node

enum tile_types {
	C,
	T,
	X,
	ERROR = -1
}

var directions: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.LEFT,
	Vector2i.DOWN,
	Vector2i.RIGHT,
]

const TILE_SIZE := Vector2(200, 200)
