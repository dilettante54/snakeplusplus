tool

extends Control

export (String) var message
export (Color) var fill_color = Color(0.53, 0.77, 0.11)
export (Color) var outline_color = Color(0.01, 0.38, 0.18)
export (int) var font_size = 50

var Letter = preload("res://ui/AnimatedLetter.tscn")

func _ready():
	var pos = 0
	
	for i in message.length():
		var new_letter = Letter.instance()
		
		new_letter.rect_position.x = pos
		new_letter.get_node("AnimatedLetter").text = message[i]
		new_letter.get_node("AnimatedLetter").add_color_override("font_color", fill_color)
		new_letter.get_node("AnimatedLetter").get("custom_fonts/font").outline_color = outline_color
		new_letter.get_node("AnimatedLetter").get("custom_fonts/font").size = font_size
		
		
		$Text.add_child(new_letter)
		
		pos += new_letter.get_node("AnimatedLetter").rect_size.x
		
	
	for i in $Text.get_child_count():
		$Text.get_child(i).get_node("AnimatedLetter/AnimationPlayer").play("Bounce")
		yield(get_tree().create_timer(0.1), "timeout")
	
