extends TileMapLayer
class_name  KnotTileMap

enum TileTransform {
	ROTATE_0 = 0,
	ROTATE_90 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	ROTATE_180 = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	ROTATE_270 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
}

@export_category("Placement Rules")
@export var can_remove_tile: bool = false
@export var can_replace_tile: bool = false
@export var must_neighbour_own_tile: bool = true
@export var must_create_valid_link: bool = true
#@export var must_create_a_link: bool = true
#@export var can_neighbour_other_players: bool = false
#@export var must_not_link_to_other_players: bool = true

"""
	Attempt to remove a tile
	Returns true if a tile is removed or false if not
"""
func remove_tile(global_pos: Vector2) -> bool:
	if not can_remove_tile: return false
	var map_position := local_to_map(to_local(global_pos))
	
	# Cell not occupied
	if get_cell_tile_data(map_position) == null: return false
	
	erase_cell(map_position)
	return true

"""
	Attempt to place a tile
	Returns true if the tile is places or false if not
"""
func place_tile(global_pos:Vector2, tile_in_hand: Tile, tile_rotation: float) -> bool:
	var map_position := local_to_map(to_local(global_pos))
	var current_cell := get_cell_tile_data(map_position)
	var neighbors := _get_neighbors(map_position)
	
	# Cell occupied
	if not can_replace_tile and not current_cell == null: return false

	# No neighbours
	if must_neighbour_own_tile and neighbors.is_empty() and not get_used_cells().is_empty(): return false
	
	# Check links
	if must_create_valid_link and not _check_links_valid(map_position, tile_in_hand, tile_rotation): return false
	
	set_cell(map_position, _tile_to_id(tile_in_hand), Vector2i(0, 0))
	_set_rotation(map_position, _angle_to_transfrom(tile_rotation))
	
	return true

func _check_links_valid(map_pos: Vector2i, tile: Tile, rot: float) -> bool:
	var links := _get_links(tile.type, _angle_to_transfrom(rot))
	
	for i in range(4):
		var dir := map_pos + Globals.directions[i]
		if get_cell_tile_data(dir):
			var id := get_cell_source_id(dir)
			var alt := get_cell_alternative_tile(dir)
	
			var valid: bool
			match Globals.directions[i]:
				Vector2i.UP: valid = links[0] == _get_links(_id_to_type(id), alt)[2]
				Vector2i.RIGHT: valid = links[1] == _get_links(_id_to_type(id), alt)[3]
				Vector2i.DOWN: valid = links[2] == _get_links(_id_to_type(id), alt)[0]
				Vector2i.LEFT: valid = links[3] == _get_links(_id_to_type(id), alt)[1]
			if not valid: return false
	
	return true

"""
	Returns an array of booleans [north, east, south, west] that is true is a link is needed and false if a link is blocked
"""
func _get_links(tile_type: int, transform: TileTransform) -> Array[bool]:
	var links: Array[bool]
	match tile_type:
		0: links = [false, true, true, false]
		1: links = [false, true, true, true]
		2: return [true, true, true, true]
	
	match transform:
		TileTransform.ROTATE_0: pass
		TileTransform.ROTATE_90: links = links.slice(3, 4) + links.slice(0, 3)
		TileTransform.ROTATE_180: links = links.slice(2, 4) + links.slice(0, 2)
		TileTransform.ROTATE_270: links = links.slice(1, 4) + links.slice(0, 1)
	
	return links

func _get_neighbors(map_pos: Vector2i) -> Array:
	var neighbors: Array[Vector2i] = []
	
	for d in Globals.directions:
		if not get_cell_tile_data(map_pos + d) == null:
			neighbors.append(d)
	
	return neighbors

func _tile_to_id(tile: Tile) -> int:
	match tile.type:
		Globals.tile_types.C: return 1
		Globals.tile_types.T: return 2
		Globals.tile_types.X: return 3
		_: return -1

func _id_to_type(id: int) -> Globals.tile_types:
	match id:
		1: return Globals.tile_types.C
		2: return Globals.tile_types.T
		3: return Globals.tile_types.X
		_: return -1

func _angle_to_transfrom(angle: float) -> TileTransform:
	angle = int(angle)%360
	match angle:
		0.0: return TileTransform.ROTATE_0
		90.0: return TileTransform.ROTATE_90
		180.0: return TileTransform.ROTATE_180
		270.0: return TileTransform.ROTATE_270
		_: return TileTransform.ROTATE_0

func _set_rotation(map_pos: Vector2i, rot: TileTransform) -> void:
	var alternate_id = get_cell_alternative_tile(map_pos)
	set_cell(map_pos, get_cell_source_id(map_pos), get_cell_atlas_coords(map_pos), alternate_id | rot)
