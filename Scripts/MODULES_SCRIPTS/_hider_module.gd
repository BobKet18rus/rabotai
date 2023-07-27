extends Node2D
class_name HIDER

func _ready() -> void:
	get_parent().queue_free()
