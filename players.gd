extends Control
class_name Players

const HAND = preload("res://hand.tscn")

@onready var active_player: int = 0

func _ready() -> void:
	for i in range(4):
		if i < Globals.num_players:
			get_child(i).set_controller(Globals.controller_type.PLAYER)
		elif i < Globals.num_cpus + Globals.num_players:
			get_child(i).set_controller(Globals.controller_type.CPU_RANDOM)
		else:
			get_child(i).queue_free()
	
	if get_child_count() >= 3:
		move_child(get_child(1), 2)
	
	get_child(0).take_turn()

func update() -> void:
	for hand: Hand in get_children():
		hand.update()

func _on_turn_finished() -> void:
	active_player = (active_player+1)%get_child_count()
	get_child(active_player).take_turn()
