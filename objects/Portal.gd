extends "res://objects/Object.gd"

signal level_completed

var portal_type

func _ready():
	connect("level_completed", get_parent(), "_on_level_completed")
	
	#20% chance a green portal drops starting from level 3, on regular levels
	if Global.current_level >= 3 and randf() < 0.20 and get_node("/root/Main/").level_type == get_node("/root/Main/").LevelType.REGULAR:
		portal_type = "bonus"
		$SpriteGreen.visible = true
		$SpriteGreen/AnimationPlayer.play("portal_spawn")
		yield($SpriteGreen/AnimationPlayer, "animation_finished")
		$SpriteGreen/AnimationPlayer.play("portal_loop")
	else:
		portal_type = "regular"
		$SpritePurple.visible = true
		$SpritePurple/AnimationPlayer.play("portal_spawn")
		yield($SpritePurple/AnimationPlayer, "animation_finished")
		$SpritePurple/AnimationPlayer.play("portal_loop")


func _on_Portal_area_entered(area):
	if "Snake" in area.name and area.is_head == true:
		emit_signal("level_completed")
		yield(get_parent(), "notify_completed")
		if portal_type == "regular":
	#		get_node("/root/Main").shrink_snake(get_node("/root/Main").snake.size(), "front")
			get_tree().change_scene("res://levels/Main.tscn")
		elif portal_type == "bonus":
			get_tree().change_scene("res://levels/BonusLevel_1.tscn")
