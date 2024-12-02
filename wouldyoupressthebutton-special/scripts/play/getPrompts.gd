extends Node

@onready var text_file_path = "res://prompts.txt"

func _ready():
	get_text_list(text_file_path)

func get_text_file_content(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	return content

func get_text_list(filePath):
	var promptList = []
	var file = FileAccess.open(filePath, FileAccess.READ)
	while file.get_position() < file.get_length():
		promptList.push_back(file.get_line())
	return promptList
