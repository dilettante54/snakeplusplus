extends Node2D

signal time_critical
signal notify_completed

const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

onready var Food = preload("res://objects/Food.tscn")
onready var Obstacle = preload("res://objects/Obstacle.tscn")
onready var Pickup = preload("res://objects/Pickup.tscn")
onready var Portal = preload("res://objects/Portal.tscn")

enum LevelType {REGULAR, BONUS}

export (LevelType) var level_type = LevelType.REGULAR


func _ready():
	randomize()
	
	Global.set_spawn_rectangle()
	
	connect("time_critical", self, "_on_time_critical", [], 4)
	
	if level_type == LevelType.REGULAR:
		for i in Global.current_level - 1:
			spawn_obstacle()
		spawn_food()
	
	notify("Level " + str(Global.current_level))
	
	
func _input(event):
	if (event is InputEventKey and event.scancode == KEY_ESCAPE and event.pressed == true):
		if $QuitPopup.visible == false:
			$QuitPopup.popup()
		else:
			$QuitPopup.hide()
	if Global.debug:
		if (event is InputEventKey and event.scancode == KEY_R and event.pressed == true):
			print("reloading...")
			get_tree().reload_current_scene()
		if (event is InputEventKey and event.scancode == KEY_S and event.pressed == true):
			print("speedup...")
			$Snake.change_speed(+1)
		if (event is InputEventKey and event.scancode == KEY_Q and event.pressed == true):
			get_tree().quit()
		if (event is InputEventKey and event.scancode == KEY_A and event.pressed == true):
			print("slowdown...")
			$Snake.change_speed(-1)
		if (event is InputEventKey and event.scancode == KEY_X and event.pressed == true):
			print("growing...")
			$Snake.grow_snake()
		if (event is InputEventKey and event.scancode == KEY_Z and event.pressed == true):
			print("shrinking...")
			$Snake.shrink_snake(1, "back")
		if (event is InputEventKey and event.scancode == KEY_E and event.pressed == true):
			print("spawning pickup...")
			spawn_pickup()
		if (event is InputEventKey and event.scancode == KEY_F and event.pressed == true):
			print("spawning food...")
			spawn_food()
		if (event is InputEventKey and event.scancode == KEY_O and event.pressed == true):
			spawn_obstacle()
		elif (event is InputEventKey and event.scancode == KEY_P and event.pressed == true):
			get_tree().paused = !get_tree().paused


func _process(delta):
	$UI/TimerBar.value = $LevelTimer.time_left
	
	
	if $LevelTimer.time_left <= 15:
		$UI/TimerBar/AnimationPlayer.play("time_critical")
		emit_signal("time_critical")

	else:
		$UI/TimerBar.get("custom_styles/fg").bg_color = Color(0.18, 0.62, 0.2)


func spawn_food():
	var new_food = Food.instance()
	$Food.add_child(new_food)


func spawn_obstacle():
	var new_obstacle = Obstacle.instance()
	$Obstacles.add_child(new_obstacle)


func spawn_pickup():
	var new_pickup = Pickup.instance()
	$Pickups.add_child(new_pickup)


func spawn_portal():
	var new_portal = Portal.instance()
	add_child(new_portal)


func game_over(reason):
	$GameOver/SubLabel.text = reason
	$GameOver.popup()


func _on_update_debug_text():
	if Global.debug:
		$UI/Debug.text = "Dir | Pos \n"
		$UI/MoveList.text = ""
		for i in $Snake.snake.size():
			$UI/Debug.text += "Snake[" + str(i) +"]: " + str($Snake.snake[i].direction) + " | " + str($Snake.snake[i].position) + "\n"
		if $Snake.moves.size() > 0:
			for i in range(0, $Snake.moves.size()):
#                if i%10 == 0:
					$UI/MoveList.text += "moves[" + str(i) +"]: " + str($Snake.moves[i]) + "\n"
		$UI/Debug.text += "moves: " + str($Snake.moves.size()) + "\n"
		$UI/Debug.text += "speed: " + str($Snake.speed) + "\n"
		if $Snake.snake.size() > 1:
			$UI/Debug.text += "distance: " + str($Snake.snake[0].position - $Snake.snake[1].position) + "\n"
		$UI/Debug.text += "dir: " + str($Snake.direction.normalized()) + "\n"
		$UI/Debug.text += "snake size: " + str($Snake.snake.size()) + "\n"
		$UI/Countdown.text = "Level time left: " + str(floor($LevelTimer.time_left)) + "\nPickup timer: " + str(floor($PickupSpawnTimer.time_left)) + "\nFoods: " + str($Food.get_child_count()) + "\nObstacles: " + str($Obstacles.get_child_count())

# should probably be a signal to the UI scene
func increase_score():
	Global.score += 1
	if Global.score > Global.highscore:
		Global.highscore = Global.score
	$UI/Score.text = "Score: " + str(Global.score)
	$UI/Highscore.text = "Highscore: " + str(Global.highscore)


func notify(message):
	$UI/PickupNotifier.text = message
	$UI/PickupNotifier/PickupNotification.play("Notify")
	yield(get_tree().create_timer(1.7), "timeout")
	$UI/PickupNotifier.text = ""
	emit_signal("notify_completed")


func _on_Walls_area_entered(area):
	if area.name == "Snake":
		game_over("You hit the wall!")


func _on_EatSelf(area):
	game_over("You ate yourself!")


func _on_Eat():
	$Snake.grow_snake()
	if level_type == LevelType.REGULAR:
		spawn_food()
	increase_score()


func _on_obstacle_crash():
	game_over("You hit an obstacle!")


func _on_LevelTimer_timeout():
	game_over("Time out!")


func _on_PickupSpawnTimer_timeout():
	if $Pickups.get_child_count() < 3 and randf() < 0.5:
		spawn_pickup()


func _on_time_critical():
	spawn_portal()


func _on_level_completed():
	$LevelTimer.set_paused(true)
	$Snake.set_physics_process(false)
	$Snake.dissolve()
	Global.current_level += 1
	notify("Level completed!")
