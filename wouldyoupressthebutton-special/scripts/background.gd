extends Node2D

@export var backgroundObj : PackedScene

@onready var timer = $Timer

func _ready() -> void:
	timer.wait_time = randf_range(15, 25)
	timer.start()

func _on_timer_timeout() -> void:
	var obj = backgroundObj.instantiate()
	add_child(obj)
	timer.wait_time = randf_range(15, 25)
	timer.start()
