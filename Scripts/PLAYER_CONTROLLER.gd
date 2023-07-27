extends Control

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if $Rect/Joy.is_pressed():
			print(event.position)
