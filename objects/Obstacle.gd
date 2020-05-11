extends "res://objects/Object.gd"

signal obstacle_crash

var fill_color = Color(0.5, 0.0, 0.0)

func _ready():
	size = $Sprite.region_rect.size
	$HitBox.shape.extents = size / 2
	$HitBox.position = pos
	
	$Sprite.flip_h  = randi()%2
	
	# gap of 15 between both obstacles leaves room for the snake
	$SpawnDetector/SpawnDetectorShape.shape.extents = Vector2(15, 15) + size / 2
	$SpawnDetector/SpawnDetectorShape.position = pos
	connect("obstacle_crash", get_node("/root/Main"), "_on_obstacle_crash")
	
	$Tween.interpolate_property($Sprite, "scale", Vector2(0.2, 0.2), Vector2(1.0, 1.0), 0.75, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0)
	$Tween.start()

func _process(delta):
	$Label.text = str(self.monitoring)

func _on_Obstacle_area_entered(area):
	if "Snake" in area.name and area.is_head == true and area.ghost == false:
		emit_signal("obstacle_crash")
