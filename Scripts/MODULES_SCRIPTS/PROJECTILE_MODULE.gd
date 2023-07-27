extends Area2D
class_name TOUCH_DAMAGE_MODULE

@export_category("Stats")
@export var damage:int

@export_category("LifeTime")
@export var life_time:float

#@export_category("Sprite")
#@export var sprite:Texture2D
#@export var is_directional:bool

@export_category("ProjectileVector")
@export var direction:Vector2

@export_category("DamageTargets")
@export var damage_to_player:bool
@export var damage_to_enemies:bool

@export_category("Owner")
@export var enemy_is_owner:bool

@export_category("AdditionalOptions")
@export var is_piercing:bool

func _ready() -> void:
	$life_time.wait_time = life_time
	
func _process(delta: float) -> void:
	if $life_time.is_stopped():
		get_parent().get_parent().queue_free()

func _on_body_entered(body: Node2D) -> void:
	if damage_to_enemies:
		if body is HITBOX_MODULE:
			body.health = body.health - (damage - (damage * body.defense))
			if not(is_piercing):
				get_parent().get_parent().queue_free()
	if damage_to_player:
		if body == sm.player:
			body.health = body.health - (damage - (damage * body.defense))
			if not(is_piercing):
				get_parent().get_parent().queue_free()
			
	
