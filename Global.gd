extends Node

export (bool) var debug = false

var spawn_x_start = 0
var spawn_y_start = 0
var spawn_x_end = 0
var spawn_y_end = 0

var current_level = 1
var highscore = 0
var score = 0

func set_spawn_rectangle():
	var spawn_rectangle = get_node("/root/Main/SpawnArea/SpawnRectangle")
	spawn_x_start = spawn_rectangle.position.x - spawn_rectangle.shape.extents.x
	spawn_y_start = spawn_rectangle.position.y - spawn_rectangle.shape.extents.y
	spawn_x_end = spawn_rectangle.position.x + spawn_rectangle.shape.extents.x
	spawn_y_end = spawn_rectangle.position.y + spawn_rectangle.shape.extents.y
