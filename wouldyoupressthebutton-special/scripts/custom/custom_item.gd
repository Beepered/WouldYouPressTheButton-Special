extends ColorRect

signal editPath

@export var pathName = ""

func _ready() -> void:
	$Name.text = pathName

func _on_edit_pressed() -> void:
	editPath.emit()

func _on_delete_pressed() -> void:
	var path = "res://prompts/" + pathName
	DirAccess.remove_absolute(path)
	queue_free()
