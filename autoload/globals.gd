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
var tile_scale := 0.25

var num_players: int = 1
var num_cpus: int = 0

enum controller_type {
	PLAYER,
	CPU_RANDOM,
}

var tile_map: KnotTileMap

var sound_fx_db: float = 0

var custom_game: bool = false
var board_width: int = 9
var board_height: int = 9
var can_remove_tile: bool
var can_replace_tile: bool
var must_neighbour_own_tile: bool
var must_create_valid_placement: bool
var must_create_a_link: bool
var must_create_a_link_with_self: bool
