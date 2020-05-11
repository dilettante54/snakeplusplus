extends PopupDialog


func _on_No_pressed():
	var file = File.new()
	file.open("user://snakeplusplus.txt", File.WRITE)
	file.store_16(Global.highscore)
	file.close()
	
	get_tree().quit()


func _on_Yes_pressed():
	get_tree().change_scene("res://levels/Main.tscn")


func _on_PopupDialog_about_to_show():
	get_tree().paused = true


func _on_PopupDialog_popup_hide():
	get_tree().paused = false
