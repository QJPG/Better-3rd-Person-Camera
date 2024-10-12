@tool
extends EditorPlugin

const TYPE_NAME := "BetterCamera3D"
const TYPE_SCRP := preload("res://addons/b3rdpscam/code/camera_support.gd")
const TYPE_ICON := preload("res://addons/b3rdpscam/bitmap.svg")

func _enter_tree() -> void:
	add_custom_type(TYPE_NAME, "Camera3D", TYPE_SCRP, TYPE_ICON)


func _exit_tree() -> void:
	remove_custom_type(TYPE_NAME)
