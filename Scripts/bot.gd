extends Sprite2D

@onready var player:Node = get_node("/root/Main_scene/GG")
var speed = 300
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
#	if player.get_local_mouse_position().x > -350 or player.get_local_mouse_position().y < 0:
	if Input.is_action_pressed("LMB") and player.position.distance_to(self.position) < 401:
		self.position = lerp(self.position, get_global_mouse_position(), 0.3)
	elif Input.is_action_pressed("LMB") and player.position.distance_to(self.position) > 400:
		self.position = lerp(self.position, (get_local_mouse_position().normalized())*400, 0.3)
	else:
		self.position = lerp(self.position, player.position, 0.8)
	
