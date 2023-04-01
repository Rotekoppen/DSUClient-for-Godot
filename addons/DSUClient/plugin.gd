@tool
extends EditorPlugin
const AUTOLOAD_NAME = "DsuClient"

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/DSUClient/singleton.tscn")


func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
