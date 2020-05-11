extends Control

func _ready():
	var file = File.new()
	file.open("user://snakeplusplus.txt", File.READ)
	Global.highscore = file.get_16()
	file.close()
	
	$Highscore.text = "Highscore: " + str(Global.highscore)
