extends Area2D

signal EatSelf

var pos = Vector2(0, 0)
var size = Vector2(20, 20) # the snake needs to be a square
var snake_color = Color(0.00, 0.37, 0.07)
var direction = Vector2(0, 0)
var ghost = false
export (bool) var is_head = false


func _draw():
	draw_rect(Rect2(pos - size / 2, size), snake_color, true)
	if is_head:
		draw_rect(Rect2(Vector2(-6, -8), Vector2(4,4)), Color(1.0, 0.3, 0.3))
		draw_rect(Rect2(Vector2(-6, 4), Vector2(4,4)), Color(1.0, 0.3 ,0.3))


func _ready():
	randomize()
	var collision_shape = RectangleShape2D.new()
	collision_shape.extents = size / 2
	$Hitbox.shape = collision_shape
	$Hitbox.position = pos
	
	var spawn_preventer_shape = CircleShape2D.new()
	spawn_preventer_shape.radius = size.x * 4
	$SpawnPreventer/CollisionShape2D.shape = spawn_preventer_shape
	$SpawnPreventer/CollisionShape2D.position = pos
	
	connect("EatSelf", get_node("/root/Main"), "_on_EatSelf")


func make_head():
	$Hitbox.disabled = false
	snake_color = Color(0.0, 0.3, 0.1)
	is_head = true
	
	# bigger no-spawn area for the head
	var spawn_preventer_shape = CircleShape2D.new()
	spawn_preventer_shape.radius = size.x * 6
	$SpawnPreventer/CollisionShape2D.shape = spawn_preventer_shape
	$SpawnPreventer/CollisionShape2D.position = Vector2(size.x / 2, size.y / 2)
	update()


func make_collidable():
	$Hitbox.disabled = false


func _on_Snake_area_entered(area):
	if is_head and "Snake" in area.name and ghost == false:
		print("you ate yourself")
		emit_signal("EatSelf", area)
