extends Node

func get_text_list(path):
	var promptList = []
	var file = FileAccess.open(path, FileAccess.READ)
	while file.get_position() < file.get_length():
		promptList.push_back(file.get_line())
	return promptList
