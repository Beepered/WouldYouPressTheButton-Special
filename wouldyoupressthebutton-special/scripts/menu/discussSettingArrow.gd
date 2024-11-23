extends Sprite2D

@export var change = 0

var minTime = 10;
var maxTime = 120

var mouseOver = false

func _input(event):
	if mouseOver && event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if(Global.discussTime + change >= minTime && Global.discussTime + change <= maxTime):
				Global.discussTime += change;


func _on_area_2d_mouse_entered() -> void:
	mouseOver = true
	modulate = Color(0, 0, 1)


func _on_area_2d_mouse_exited() -> void:
	mouseOver = false
	modulate = Color(1, 1, 1)
