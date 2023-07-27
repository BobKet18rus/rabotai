extends CharacterBody2D
class_name projectile_class

var speed = 2000
@onready var direction = get_parent().get_parent().get_player().get_dir()
@onready var player_form = get_parent().get_parent().get_player().get_form()

func _ready():
	var intend
	if direction == "right":
		intend = 35
	elif direction == "left":
		intend = -35
		
	if player_form == "box":
		$Sprite2D.texture = load("res://Sprites/stuff/box.png")
		
	position = get_parent().get_parent().get_player().get_pos()
	position.x += intend
	
func _physics_process(_delta):
	if direction == "right":
		velocity.x = speed
	elif direction == "left":
		velocity.x = -speed
	set_velocity(velocity)
	move_and_slide()
