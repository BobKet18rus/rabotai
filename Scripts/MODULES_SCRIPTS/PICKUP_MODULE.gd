extends Area2D

@export var amount:float

func _ready() -> void:
	
	self.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body: Node2D) -> void:
	if body == sm.player:
		get_parent().get_parent().add(amount)
