# Script that is set to Autoload
# Go to: Project, Project Settings, Globals

extends Node

var discussTime = 40
var voteTime = 10

var playerNames = []

var custom_folder_path = OS.get_executable_path().get_base_dir() + "/custom-prompts/"
var chance_folder_path = OS.get_executable_path().get_base_dir() + "/prompt chances/"
var file_path = "default"
var default_file_path = "res://prompts/prompts.txt"
