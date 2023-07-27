extends Node2D
class_name H_rope

@onready var player_area:Node = sm.player.get_node("ring_area")
@onready var player_spr:Node = sm.player.get_node("sprite")

func _physics_process(delta) -> void:
	pass


func _on_area_area_entered(area) -> void:
	if (sm.player.state == sm.JUMP or sm.FALL) and sm.player.ring_timer.is_stopped() and area == player_area:
		sm.player.state = sm.H_ROPE
		sm.player.position.y = self.position.y + 75
		sm.player.velocity.y = 0


func _on_area_area_exited(area) -> void:
	pass


func _on_borders_area_entered(area) -> void:
	if sm.player.state == sm.H_ROPE and area == player_area:
		sm.player.state = sm.FALL
