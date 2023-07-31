extends Polygon2D
@onready var player = get_parent().get_node("GG")

func _process(delta: float) -> void:
	self.position = player.position + Vector2(40, 0)
#	self.position = get_global_mouse_position()
