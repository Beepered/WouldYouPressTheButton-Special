extends CanvasLayer


@onready var timer = $Timer
func _ready() -> void:
	timer.timeout = Global.discussTime

func _process(delta: float) -> void:
	pass

func begin_discussion():
	timer.start()
