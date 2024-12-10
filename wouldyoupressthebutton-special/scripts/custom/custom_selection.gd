extends Node2D


@onready var main = $main
@onready var create = $create
@onready var edit = $"edit"

@onready var useSelect = $"main/use select"
@onready var createSelect = $"main/create select"
@onready var editSelect = $"main/edit select"

func _ready() -> void:
	main.visible = true
	create.visible = false
	edit.visible = false

func _on_create_select_pressed() -> void:
	main.visible = false
	create.visible = true
	
func _on_edit_select_pressed() -> void:
	main.visible = false
	edit.visible = true

func _on_back_pressed() -> void:
	main.visible = true
	create.visible = false
	edit.visible = false
