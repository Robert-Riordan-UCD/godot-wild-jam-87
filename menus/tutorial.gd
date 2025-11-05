extends CanvasLayer

signal _advance

signal rotated
signal dropped
signal passed
signal finish_tutorial

@export var players: Array[Hand]

@onready var select_tile: HBoxContainer = $VBoxContainer/SelectTile
@onready var rotate_tile: HBoxContainer = $VBoxContainer/RotateTile
@onready var return_tile: HBoxContainer = $VBoxContainer/ReturnTile
@onready var pass_turn: HBoxContainer = $VBoxContainer/Pass
@onready var other_players: HBoxContainer = $VBoxContainer/OtherPlayers
@onready var place_tile: HBoxContainer = $VBoxContainer/PlaceTile
@onready var place_tile_note: HBoxContainer = $VBoxContainer/PlaceTileNote
@onready var thats_it: HBoxContainer = $VBoxContainer/ThatsIt

const MAIN_MENU = "res://menus/main_menu.tscn"

var controller: BaseController


func _ready() -> void:
	await get_tree().process_frame

	var removed_actions := InputMapEdit.remove_input_actions()
	InputMapEdit.restore_input_action("pick_up_tile", removed_actions["pick_up_tile"])
	
	var _players: Array = get_tree().get_nodes_in_group("player")
	
	if _players.is_empty():
		queue_free()
		return
	
	controller = _players[0]
	
	await _tile_clicked()
	await get_tree().process_frame
	
	InputMapEdit.remove_input_action("pick_up_tile")
	select_tile.visible = false
	InputMapEdit.restore_input_action("rotate_tile_cw", removed_actions["rotate_tile_cw"])
	InputMapEdit.restore_input_action("rotate_tile_acw", removed_actions["rotate_tile_acw"])
	rotate_tile.visible = true
	
	await rotated
	await get_tree().process_frame
	
	InputMapEdit.restore_input_action("drop_tile", removed_actions["drop_tile"])
	rotate_tile.visible = false
	return_tile.visible = true
	
	await dropped
	await get_tree().process_frame
	
	InputMapEdit.remove_input_action("rotate_tile_cw")
	InputMapEdit.remove_input_action("rotate_tile_acw")
	InputMapEdit.remove_input_action("drop_tile")
	return_tile.visible = false
	InputMapEdit.restore_input_action("pass", removed_actions["pass"])
	pass_turn.visible = true
	
	await passed
	await get_tree().process_frame
	
	InputMapEdit.remove_input_action("pass")
	pass_turn.visible = false
	other_players.visible = true
	
	await _all_players_end_turn()
	await get_tree().process_frame
	
	other_players.visible = false
	InputMapEdit.restore_input_action("pick_up_tile", removed_actions["pick_up_tile"])
	InputMapEdit.restore_input_action("rotate_tile_cw", removed_actions["rotate_tile_cw"])
	InputMapEdit.restore_input_action("rotate_tile_acw", removed_actions["rotate_tile_acw"])
	InputMapEdit.restore_input_action("drop_tile", removed_actions["drop_tile"])
	InputMapEdit.restore_input_action("place_tile", removed_actions["place_tile"])
	place_tile.visible = true
	place_tile_note.visible = true
	
	await controller.end_turn
	await get_tree().process_frame
	
	InputMapEdit.restore_input_actions(removed_actions)
	place_tile.visible = false
	place_tile_note.visible = false
	thats_it.visible = true
	
	await get_tree().create_timer(0.25).timeout
	await finish_tutorial
	
	SceneTransition.change_scene(MAIN_MENU)


func _tile_clicked() -> void:
	var tiles: Array = get_tree().get_nodes_in_group("tile")
	
	for tile in tiles:
		if tile is Tile:
			tile.tile_clicked.connect(_progress)
	
	await _advance

	for tile in tiles:
		if tile is Tile:
			tile.tile_clicked.disconnect(_progress)
	
	return


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate_tile_acw") or event.is_action_pressed("rotate_tile_cw"):
		rotated.emit()
	if event.is_action_pressed("drop_tile"):
		dropped.emit()
	if event.is_action_pressed("pass") :
		passed.emit()
	if event is InputEventKey or event is InputEventMouseButton:
		finish_tutorial.emit()


func _progress(_unused) -> void:
	_advance.emit()


signal _all_turns_ended
var turns_remaining: int
func _all_players_end_turn() -> void:
	turns_remaining = 0
	for player in players:
		if player:
			player.turn_finished.connect(_other_player_ended_turn)
			turns_remaining += 1
	await _all_turns_ended
	for player in players:
		if player:
			player.turn_finished.disconnect(_other_player_ended_turn)


func _other_player_ended_turn(_unused) -> void:
	turns_remaining -= 1
	if turns_remaining <= 0:
		_all_turns_ended.emit()
