extends Node2D

@export var backgroundObj : PackedScene

@onready var timer = $Timer
var spawnMin = 10
var spawnMax = 25

func _ready() -> void:
	timer.wait_time = randf_range(spawnMin, spawnMax)
	timer.start()

func _on_timer_timeout() -> void:
	var obj = backgroundObj.instantiate()
	add_child(obj)
	timer.wait_time = randf_range(spawnMin, spawnMax)
	timer.start()
