extends Node2D
class_name Ring

@onready var player_area:Node = sm.player.get_node("ring_area")
@onready var player_spr:Node = sm.player.get_node("sprite")
var on_ring:bool = false

func _physics_process(_delta) -> void:
	if on_ring == true and sm.player.state == sm.RING:
		sm.player.position = lerp(sm.player.position, self.position + Vector2(0, 100), 0.6)
#func _physics_process(delta):
#	if $area.overlaps_area(player_area) and (player.state == sm.JUMP or sm.FALL) and player.ring_timer.is_stopped():
#		player.state = sm.RING
#		player.position = lerp(player.position, self.position + Vector2(0, 100), 0.3)
#		player.velocity = Vector2.ZERO
func _on_area_area_entered(area) -> void:
	if (sm.player.state == sm.JUMP or sm.FALL) and sm.player.ring_timer.is_stopped() and area == player_area:
		on_ring = true
		sm.player.state = sm.RING
		sm.player.velocity = Vector2.ZERO
	
func _on_area_area_exited(area) -> void:
	if area == player_area:
		on_ring = false
