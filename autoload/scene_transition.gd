extends CanvasLayer

@onready var texture_rect: TextureRect = $TextureRect

func change_scene(new_scene: String, min_duration: float=1.5) -> void:
	visible = true
	texture_rect.material.set_shader_parameter("left_bound", 0.0);
	texture_rect.material.set_shader_parameter("right_bound", 0.0);
	
	var tween: Tween = create_tween()
	tween.tween_property(texture_rect, "material:shader_parameter/right_bound", 1.0, min_duration/2.0)	
	
	await tween.finished
	get_tree().change_scene_to_file(new_scene)
	get_tree().root.ready
	
	tween = create_tween()
	tween.tween_property(texture_rect, "material:shader_parameter/left_bound", 1.0, min_duration/2.0	)	
	await tween.finished
	
	visible = false
