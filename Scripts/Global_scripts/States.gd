extends Node

@onready var player:Node = get_node("/root/Main_scene/GG")

enum {
	IDLE = 1,
	MOVE = 2,
	FALL = 3,
	JUMP = 4,
	RING = 5,
	H_ROPE = 6,
	D_ROPE = 7,
	V_ROPE = 8,
	LEDGE = 9,
	WALL = 10,
	SHOOTING = 11
}
