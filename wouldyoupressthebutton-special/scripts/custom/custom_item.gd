extends ColorRect

signal editItem(pathName)

@export var pathName = ""

func _ready() -> void:
	$Name.text = pathName

func _on_edit_pressed() -> void:
	editItem.emit(pathName)

func _on_delete_pressed() -> void:
	var path = Global.custom_folder_path + pathName + ".txt"
	DirAccess.remove_absolute(path)
	queue_free()
