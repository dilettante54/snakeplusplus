extends "res://objects/Object.gd"

signal grabbed_pickup

enum PickupType {SPEEDUP, SLOWDOWN, GHOST, DIET, CHONK, BONUS_TIME, BOUNTY, OBSTACLES}

var potion_color
export (PickupType) var pickup_effect = PickupType.SLOWDOWN

func _ready():
	randomize()
	connect("grabbed_pickup", get_node("/root/Main/Snake"), "_on_grabbed_pickup")
	
	if not is_fixed:
		pickup_effect = randi()%PickupType.size()
	
	$PivotPoint/AnimationPlayer.play("rotation")
	$Tween.interpolate_property($PivotPoint/Potion, "scale", Vector2(0.2, 0.2), Vector2(1.0, 1.0), 0.75, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0)
	$Tween.start()
	yield($Tween, "tween_completed")
	$PivotPoint/Particles2D.emitting = true
	$Label.text = str(PickupType.keys()[pickup_effect])


func _on_HitBox_area_entered(area):
	if "Snake" in area.name:
		match pickup_effect:
			PickupType.SPEEDUP:
				emit_signal("grabbed_pickup", "SPEEDUP", "Speedup!")
			PickupType.SLOWDOWN:
				emit_signal("grabbed_pickup", "SLOWDOWN", "Slowdown!")
			PickupType.GHOST:
				emit_signal("grabbed_pickup", "GHOST", "Ghost!")
			PickupType.DIET:
				emit_signal("grabbed_pickup", "DIET", "Diet!")
			PickupType.CHONK:
				emit_signal("grabbed_pickup", "CHONK", "Chonk!")
			PickupType.BONUS_TIME:
				emit_signal("grabbed_pickup", "BONUS_TIME", "Extra time!")
			PickupType.BOUNTY:
				emit_signal("grabbed_pickup", "BOUNTY", "Bounty!")
			PickupType.OBSTACLES:
				emit_signal("grabbed_pickup", "OBSTACLES", "More rocks!")
			_: #for any pickups not fitting the criteria
				print("undefined pickup effect")
		self.queue_free()
