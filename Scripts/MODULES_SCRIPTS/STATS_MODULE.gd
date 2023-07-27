extends Node2D
class_name STATS_MODULE

@export_category("HealthParameters")
@export var hitbox:HITBOX_MODULE
@export var health:int
@export_range(0, 1, 0.01) var defense:int

@export_category("SpeedParameters")
@export var speed:int
@export_range(0, 1, 0.01) var friction:float
@export_range(0, 1, 0.01) var acceleration:float

@export_category("DamageParameters")
@export var damage_areas:Node2D
@export var damage:int
