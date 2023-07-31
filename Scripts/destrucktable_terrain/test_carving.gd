extends Node2D

@onready var b = get_parent().get_node("b")#надо потом поменять
@onready var instance = load("res://test_carving.tscn")
@onready var player = get_parent().get_node("GG")
@onready var tex = preload("res://icon.png")
var eat_area_direction:int
var eat_lenght:Vector2 = Vector2(100, 0)


func _ready() -> void:
	pass
	
func eat_area_direction_define():
	pass

func _input(event):
	if Input.is_action_just_pressed("left"):
		eat_area_direction = -1
	elif Input.is_action_just_pressed("right"):
		eat_area_direction = 1
		
	$col/col_polygon.polygon = self.polygon
	if Input.is_action_just_pressed("LMB"):
		var dark_poly = Polygon2D.new()
		var temp_pos = []
		for i in b.polygon.size():
#			temp_pos.append(b.polygon[i]+get_global_mouse_position())
			temp_pos.append(b.polygon[i]+player.position+(eat_lenght*eat_area_direction))
		dark_poly.polygon = temp_pos
		var new_poly = Geometry2D.clip_polygons(self.polygon, dark_poly.polygon)

		if not(new_poly.is_empty()):
			self.polygon = new_poly[0]
		else:
			self.queue_free()
			
		if new_poly.size() > 1:
			for i in new_poly.size()-1:
				var x = instance.instantiate()
				x.polygon = PackedVector2Array(new_poly[i+1])
				x.texture = tex
				x.texture_repeat = 2
				get_parent().add_child(x)

