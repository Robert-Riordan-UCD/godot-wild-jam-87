extends Node

# Signal called from setting menu
@warning_ignore("unused_signal")
signal volume_changed
@warning_ignore("unused_signal")
signal birds_changed

@export var volume_db: float = 0
@export var bird_volume_db: float = 0

@onready var harp_slow: AudioLevel = $HarpSlow
@onready var birds: AudioStreamPlayer = $Birds


func _ready() -> void:
	harp_slow.increase_level()


func _on_timer_timeout() -> void:
	if randf() > 0.5 or not harp_slow._active:
		harp_slow.increase_level()
	else:
		harp_slow.decrease_level()


func _on_birds_changed() -> void:
	birds.volume_db = bird_volume_db
