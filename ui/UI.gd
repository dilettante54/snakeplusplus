extends Control

func _ready():
	$Level.text = "Level: " + str(Global.current_level)
	$Highscore.text = "Highscore: " + str(Global.highscore)
	$PickupNotifier.text = ""
	
	if Global.debug:
		$Countdown.visible = true
		$MoveList.visible = true
		$Debug.visible = true
