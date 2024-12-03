extends Node

@onready var text_file_path = "res://prompts.txt"

func get_text_list():
	var promptList = []
	var file = FileAccess.open(text_file_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		promptList.push_back(file.get_line())
	return promptList
