# generic script for object with a hitbox and spawn overlap avoidance logic
# starts with hitbox monitoring off & visible off, turn on when a spawn point is found

extends Area2D

var pos = Vector2(0, 0)
export (Vector2) var size = Vector2(25, 25)
export (bool) var is_fixed = false

signal overlap_checked

func _ready():
	if is_fixed:
		deactivate()
		self.visible = true
	else:
		generate_position()
	
	if Global.debug:
		$Label.visible = true


func _physics_process(delta):
	overlap_check()
	yield(self, "overlap_checked")
	if $SpawnDetector.get_overlapping_areas().empty():
		deactivate()
		self.visible = true


func overlap_check():
	if not $SpawnDetector.get_overlapping_areas().empty():
		generate_position()
	emit_signal("overlap_checked")


func generate_position():
	self.position = Vector2(rand_range(Global.spawn_x_start, Global.spawn_x_end),
							rand_range(Global.spawn_y_start, Global.spawn_y_end))
							

func deactivate():
	$SpawnDetector.monitoring = false
	self.monitoring = true
	set_physics_process(false)
