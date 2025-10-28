extends HBoxContainer

@export var display_time: float = 30
@export var fade_time: float = 0.75

func _ready() -> void:
	await get_tree().create_timer(display_time).timeout
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, fade_time)
	await tween.finished
	queue_free()
