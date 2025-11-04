extends Node

@onready var tutorial: CanvasLayer = $"../Tutorial"

func _ready() -> void:
	tutorial.queue_free()
