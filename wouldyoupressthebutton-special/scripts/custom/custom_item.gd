extends ColorRect

signal editItem(pathName)

@export var pathName = ""

func _ready() -> void:
	$Name.text = pathName.substr(0, pathName.find(".txt"))

func _on_edit_pressed() -> void:
	editItem.emit(pathName)

func _on_delete_pressed() -> void:
	var path = Global.custom_folder_path + pathName
	DirAccess.remove_absolute(path)
	queue_free()
