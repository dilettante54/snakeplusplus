extends Button

export (String) var target_scene_path = ""

func _ready():
	get("custom_fonts/font").outline_color = Color(0.09, 0.42, 0.13)


func _on_Button_mouse_entered():
	get("custom_fonts/font").outline_color = Color(0.38, 0.00, 0.59)


func _on_Button_mouse_exited():
	get("custom_fonts/font").outline_color = Color(0.09, 0.42, 0.13)


func _on_Button_pressed():
	if target_scene_path == "Exit":
		get_tree().quit()
	else:
		get_tree().change_scene(target_scene_path)
