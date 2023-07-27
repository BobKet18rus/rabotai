extends Node2D

func add(a):
	sm.player.money = sm.player.money + a
	queue_free()
