extends Button

var hovered = false

var time = 0.5
var rotationSpeed = 0.0005

func _ready() -> void:
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _process(delta: float) -> void:
	if(hovered):
		time += delta
		rotation += sin(time * 2) * rotationSpeed

func _on_mouse_entered() -> void:
	scale *= 1.15
	hovered = true

func _on_mouse_exited() -> void:
	scale = Vector2(1, 1)
	hovered = false
	rotation = 0
