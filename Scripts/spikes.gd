extends Area2D
class_name Danger
	
func _on_body_entered(body) -> void:
	if body == sm.player:
		sm.player.die()
