extends CanvasLayer

@onready var player_count: Label = $VBoxContainer/Setup/Playes/HBoxContainer/PlayerCount
@onready var cpu_count: Label = $VBoxContainer/Setup/CPUs/HBoxContainer/CPUCount

const COMPETITIVE = "res://modes/competitive.tscn"
const CREATIVE = "res://modes/creative.tscn"

@export var max_total_players: int = 4

func _on_play_pressed() -> void:
	Globals.num_players = int(player_count.text)
	Globals.num_cpus = int(cpu_count.text)
	get_tree().change_scene_to_file(COMPETITIVE)

func _on_creative_pressed() -> void:
	get_tree().change_scene_to_file(CREATIVE)

func _on_credits_pressed() -> void:
	push_warning("Not implemented")

func _on_decrease_players_pressed() -> void:
	player_count.text = str(max(int(player_count.text)-1, 0))

func _on_increase_players_pressed() -> void:
	player_count.text = str(min(int(player_count.text)+1, max_total_players-int(cpu_count.text)))

func _on_decrease_cp_us_pressed() -> void:
	cpu_count.text = str(max(int(cpu_count.text)-1, 0))

func _on_increase_cp_us_pressed() -> void:
	cpu_count.text = str(min(int(cpu_count.text)+1, max_total_players-int(player_count.text)))
