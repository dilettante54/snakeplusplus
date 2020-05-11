extends "res://objects/Object.gd"

signal food_eaten

func _ready():
	var collision_shape = RectangleShape2D.new()
	var spawndetector_collision_shape = CircleShape2D.new()
	
	$Sprite.region_rect = Rect2(randi()%5 * 32 + 4, randi()%3 * 32 + 4, 24, 24)
	
	collision_shape.extents = $Sprite.region_rect.size / 2
	
	# the +35 is the obstacle size plus a margin, so that food doesn't spawn within obstacles;
	# should be linked to the actual obstacle size
	spawndetector_collision_shape.radius = $Sprite.region_rect.size.x / 2 + 35
	$HitBox.shape = collision_shape
	$SpawnDetector/SpawnDetectorShape.shape = spawndetector_collision_shape
	connect("food_eaten", get_node("/root/Main"), "_on_Eat")
	
	$Tween.interpolate_property($Sprite, "scale", Vector2(0.2, 0.2), Vector2(1.0, 1.0), 0.75, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0)
	$Tween.start()
	
	$AnimationPlayer.play("float")


func _on_Food_area_entered(area):
	if "Snake" in area.name and area.is_head == true:
		emit_signal("food_eaten")
		self.queue_free()
