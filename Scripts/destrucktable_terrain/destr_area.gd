extends Polygon2D
class_name aaaa

@onready var new_polygon = Polygon2D.new()
@onready var tex = preload("res://icon.png")
@onready var island_instance = load("res://Scenes/destructible_terrain/destr_area.tscn").instantiate()
@onready var eat_area = get_tree().get_node("/root/Main_scene/GG/eat_area")

func _ready():
	pass
	
func _process(delta):
	var res = Geometry2D.clip_polygons(self.polygon, eat_area.polygon)
	for i in range(len(res)):
		var island = island_instance
		island.polygon = res[i]
		island.texture = tex
		island.get_node("/col/col_polygon").polygon = res[i]
		get_tree().get_node("/root/Main_scene").add_child(island)
