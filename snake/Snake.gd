extends Node2D

signal update_debug_text

const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

onready var Snake = preload("res://snake/SnakeElement.tscn")

var snake = [] # stores actual snake segment nodes
var moves = [] # array of moves to cycle through
var speeds = [1.0, 2.0, 5.0, 10.0] # speeds need to result in an integer for (size/speed)
var speed = 2.0 # this needs to be a float, hence it's written as 1.0 ('1' would just be an int)
var size
var can_turn = true
export var direction = LEFT


func _ready():
	connect("update_debug_text", get_node("/root/Main"), "_on_update_debug_text")
	
	size = $SnakeElement.size.x
	snake.push_front($SnakeElement)
	snake[0].name = "Snake"
	
	snake[0].direction = direction
	snake[0].make_head()
	
	for i in range(0, max(4, Global.score / 2)):
		grow_snake()


func _input(event):
	if event.is_action_pressed("ui_up") and direction != DOWN and direction != UP and can_turn:
		direction = UP
		snake[0].rotation_degrees = 90
		turn_preventer()
	elif event.is_action_pressed("ui_down")  and direction != UP and direction != DOWN and can_turn:
		direction = DOWN
		snake[0].rotation_degrees = -90
		turn_preventer()
	elif event.is_action_pressed("ui_left") and direction != RIGHT and direction != LEFT and can_turn:
		direction = LEFT
		snake[0].rotation_degrees = 0
		turn_preventer()
	elif event.is_action_pressed("ui_right")  and direction != LEFT and direction != RIGHT and can_turn:
		direction = RIGHT
		snake[0].rotation_degrees = 180
		turn_preventer()


func _physics_process(delta):
	# moves for the head
	if snake:
		snake[0].direction = direction * speed
		snake[0].position += snake[0].direction
		moves.push_front(direction * speed)

	# moves for the body
	for i in range(1, snake.size()):
		snake[i].direction = moves[i * (size/speed)]
		snake[i].position += snake[i].direction
	moves.pop_back()
	
	emit_signal("update_debug_text")

# BUG: if growing while turning the new segments are sometimes not aligned
func grow_snake():
	var new_snake = Snake.instance()
	var new_moves = snake[-1].direction * speed
	if moves.size() > 0:
		new_moves = moves[-1] 
	#new snake spawned after the tail [-1], clamping is necessary so there is no gap between the new segment and the previous
	new_snake.position = snake[-1].position - (snake[-1].direction.clamped(1.0) * size)
	new_snake.direction = snake[-1].direction
	new_snake.snake_color = snake[-1].snake_color.lightened(0.01)
	if snake[0].ghost == true:
		new_snake.set_modulate(Color(1, 1 ,1, 0.2))
	#not very elegant
	if snake.size() > 2:
		new_snake.make_collidable()
	snake.push_back(new_snake)
	add_child(new_snake)
	#need to append a move for each pixel of a snake's length
	for i in (size/speed):
		moves.append(new_moves)


func shrink_snake(length, shrink_direction):
	var segments_to_despawn = get_children()
	
	if shrink_direction == "back":
		if snake.size() > 1:
			for i in length:
				snake.pop_back()
				segments_to_despawn.back().queue_free()
				segments_to_despawn.pop_back()
				yield(get_tree().create_timer(0.1), "timeout")
				for x in size/speed:
					moves.pop_back()
	elif shrink_direction == "front":
		if snake.size() > 1:
			for i in length:
				snake.pop_front()
				segments_to_despawn.front().queue_free()
				segments_to_despawn.pop_front()
				yield(get_tree().create_timer(0.167 * speed), "timeout")
				for x in size/speed:
					moves.pop_front()


func change_speed(speed_change):
	var previous_speed = speed
	var segment_directions = []
	var original_destinations = []
	var new_speed_destinations = []
	var counter = 1
	
	# prevent crashing if new speed would be out of bounds
	if speed + speed_change < speeds[0]: 
		return
	elif speed + speed_change > speeds[-1]:
		return
   
	speed = speeds[speeds.find(speed) + speed_change]
	
	# capture where the snake would end up with the old speed
	original_destinations = capture_original_destinations(previous_speed, speed)
	
	# adjust all move vectors by speed change factor
	for i in range(0, moves.size()):
		moves[i] *= speed/previous_speed
	
	emit_signal("update_debug_text")
	
	# create a list of new moves based on every nth move, corresponding to the first move of a segment
	for i in range(1, snake.size()):
		segment_directions.append(moves[i * (size/previous_speed) - 1])
	
	# reset, then fill up moves list with adjusted move vectors
	moves = []
	for i in range(0, segment_directions.size()):
		for x in range(0, size/speed):
			moves.append(segment_directions[i])
			
	# calculate end positions for each segment, using the new speed (sum moves 0-9 / 0-4 / 0-1 / 0, etc)
	for i in moves.size():
		if counter <= snake.size() - 1:
			var new_moves = Vector2(0,0)
			for x in range(i * size / speed, counter * size / speed):
				new_moves += moves[x]
			new_speed_destinations.append(new_moves)
			counter += 1
	
	# apply adjustment vectors here
	for i in original_destinations.size():
		moves[i * size/speed] -= (snake[i+1].position + new_speed_destinations[i] - original_destinations[i])
	
	emit_signal("update_debug_text")


func capture_original_destinations(previous_speed, speed):
	var original_vectors = []
	var original_destinations = []
	var segment_moves = size / previous_speed
	var counter = 0
	for i in range(1, snake.size()):
		if counter <= snake.size() - 1:
			var original_moves = Vector2(0,0)
			for x in range(counter * segment_moves, (counter+1) * segment_moves):
				original_moves += moves[x] #sum up the moves for each segment using the prev speed and store it
			original_vectors.append(original_moves)
		counter += 1
	
	for i in original_vectors.size():
		original_destinations.append(snake[i+1].position + original_vectors[i])
		
	return(original_destinations)


func turn_preventer():
#	can_turn = false
#	yield(get_tree().create_timer(0.016666667 * size / speed), "timeout")
#	can_turn = true
	pass


func dissolve():
	for s in snake:
		$Tween.interpolate_property(s, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.2, Tween.TRANS_SINE, Tween.EASE_IN)
		$Tween.start()


func _on_grabbed_pickup(pickup_effect, message):
	get_parent().notify(message)
	match pickup_effect:
		"SPEEDUP":
			change_speed(+1)
		"SLOWDOWN":
			change_speed(-1)
		"GHOST":
			get_child(0).ghost = true
			for s in snake:
				$Tween.interpolate_property(s, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.2), 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
				$Tween.start()
			yield(get_tree().create_timer(4.0), "timeout")
			for s in snake:
				$Tween.interpolate_property(s, "modulate", Color(1, 1, 1, 0.2), Color(1, 1, 1, 1), 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
				$Tween.start()
			get_child(0).ghost = false
		"DIET":
			shrink_snake(ceil(snake.size() / 2), "back")
		"CHONK":
			for i in snake.size():
				yield(get_tree().create_timer(0.1), "timeout")
				grow_snake()
		"BONUS_TIME":
			get_node("/root/Main/LevelTimer").start(min(get_node("/root/Main/LevelTimer").wait_time, get_node("/root/Main/LevelTimer").time_left + 15))
		"BOUNTY":
			for i in randi() % 5 + 1:
				get_parent().spawn_food()
		"OBSTACLES":
			if get_node("/root/Main/Obstacles").get_child_count() < 40:
				for i in range(0, randi() % 10 + 1):
					get_parent().spawn_obstacle()
