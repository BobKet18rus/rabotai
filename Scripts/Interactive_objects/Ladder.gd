extends Node2D

#НЕДОДЕЛАНО

@onready var player:Node = get_node("/root/Main_scene/GG")
@onready var player_area:Node = player.get_node("ring_area")
@onready var player_spr:Node = player.get_node("sprite")
@onready var ladder_ray:bool = player.get_node("ladder_ray").is_colliding()
var is_entered:bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	if Input.is_action_pressed("up") and is_entered == true:
		player.state = sm.V_ROPE
		player.position.x = self.position.x
		player.velocity.x = 0

func _on_area_2d_body_entered(player) -> void:
	is_entered = true

func _on_area_2d_body_exited(player) -> void:
	is_entered = false
