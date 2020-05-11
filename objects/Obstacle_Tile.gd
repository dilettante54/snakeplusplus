extends "res://objects/Object.gd"

signal obstacle_crash

func _ready():
	size = $TileMap.cell_size
	$HitBox.shape.extents = size / 2
	$HitBox.position = pos + size / 2
	
	# 10 is hard input for snake size
	$SpawnDetector/SpawnDetectorShape.shape.extents = Vector2(10, 10) + size / 2
	$SpawnDetector/SpawnDetectorShape.position = pos + size / 2
	connect("obstacle_crash", get_node("/root/Main"), "_on_obstacle_crash")


func _process(delta):
	$Label.text = str(self.monitoring)


func _on_Obstacle_area_entered(area):
	if area.name == "Snake":
		emit_signal("obstacle_crash")
