extends Node2D

signal CustomFinished

@onready var choiceMenu = $"choice menu"
@onready var createMenu = $"create menu"

@onready var mainBack = $main/MainBack

func _ready() -> void:
	choiceMenu.visible = true
	createMenu.visible = false
	fill_choices()

func _on_create_select_pressed() -> void:
	choiceMenu.visible = false
	createMenu.visible = true
	mainBack.visible = false
	createMenu.creating = true

func _on_back_pressed() -> void:
	choiceMenu.visible = true
	createMenu.visible = false
	mainBack.visible = true

func _on_main_back_pressed() -> void:
	CustomFinished.emit()
	queue_free()

@export var customItem: PackedScene
func create_item(pathName):
	var item = customItem.instantiate()
	item.pathName = pathName
	item.editItem.connect(edit_item)
	$"choice menu/ScrollContainer/VBoxContainer".add_child(item)

func edit_item(path):
	_on_create_select_pressed()
	createMenu.creating = false
	createMenu._load_path(path)

func fill_choices(): # fill from custom folder
	var dir = DirAccess.open(Global.custom_folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				create_item(file_name)
			file_name = dir.get_next()
