extends Node2D

signal CustomFinished

@onready var choiceMenu = $"choice menu"
@onready var createMenu = $"create menu"

@onready var mainBack = $main/MainBack

func _ready() -> void:
	choiceMenu.visible = true
	createMenu.visible = false

func _on_create_select_pressed() -> void:
	choiceMenu.visible = false
	createMenu.visible = true
	mainBack.visible = false

func _on_back_pressed() -> void:
	choiceMenu.visible = true
	createMenu.visible = false
	mainBack.visible = true

func _on_main_back_pressed() -> void:
	CustomFinished.emit()
	queue_free()

@export var customItem: PackedScene
func createPath(pathName):
	var item = customItem.instantiate()
	item.pathName = pathName
	$"choice menu/ScrollContainer/VBoxContainer".add_child(item)
