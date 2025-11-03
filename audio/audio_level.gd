extends AudioStreamPlayer
class_name AudioLevel

@onready var _active: bool = false


func _ready() -> void:
	volume_db = -50
	Audio.volume_changed.connect(_on_volume_changed)


# Returns true if the level increased
func increase_level() -> bool:
	if _active:
		var children: Array = get_children()
		children.shuffle()
		for child in children:
			if child is AudioLevel:
				var success: bool = child.increase_level()
				if success: return true
	else:
		_active = true
		_set_level(Audio.volume_db)
		return true
	return false


# returns true if the level decreased
func decrease_level() -> bool:
	if not _active:
		return false

	var children: Array = get_children()
	children.shuffle()
	for child in children:
		if child is AudioLevel:
			var success: bool = child.decrease_level()
			if success: return true

	_active = false
	_set_level(-50)
	return true


func _set_level(level: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "volume_db", level, 0.2)


func _on_volume_changed() -> void:
	if _active:
		volume_db = Audio.volume_db
