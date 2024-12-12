extends ColorRect

@onready var direction = randi_range(0, 1) # 0 left, 1 right
@onready var xMove = randf_range(10, 20)

func _ready() -> void:
	var _size = randi_range(300, 500)
	size = Vector2(_size, _size)
	var xPos = _size * -1 if direction == 0 else get_viewport().size.x + _size
	var yPos = randi_range(200, get_viewport().size.y - 200)
	position = Vector2(xPos, yPos)
	color = Color(randf(), randf(), randf())
	modulate.a = randf_range(0.2, 0.5)
	if direction == 1:
		xMove *= -1

func _process(delta: float) -> void:
	rotation += 0.07 * delta
	position.x += xMove * delta
