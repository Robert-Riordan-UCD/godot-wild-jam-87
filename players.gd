extends Control
class_name Players

const HAND = preload("res://hand.tscn")

func _ready() -> void:
	var num_hands: int = Globals.num_cpus + Globals.num_players
	for i in range(num_hands, 4):
		get_child(i).queue_free()

func update() -> void:
	for hand: Hand in get_children():
		hand.update()
