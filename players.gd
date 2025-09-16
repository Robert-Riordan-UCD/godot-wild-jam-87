extends Control
class_name Players

const HAND = preload("res://hand.tscn")

@onready var active_player: int = 0

func _ready() -> void:
	var num_hands: int = Globals.num_cpus + Globals.num_players
	for i in range(num_hands, 4):
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
