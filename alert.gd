extends Label
class_name Alert

func alert(t: String, pos: Vector2, duration: float) -> void:
	global_position = pos
	text = t
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "self_modulate", Color(1.0, 1.0, 1.0, 0.0), duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	
	queue_free()
