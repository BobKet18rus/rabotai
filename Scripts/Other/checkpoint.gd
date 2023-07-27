extends Node2D
class_name Checkpoint

var is_initial:bool 

@onready var player = get_node("/root/Main_scene/GG")

func _on_area_2d_body_entered(player):
	player.current_checkpoint_position = self.position
