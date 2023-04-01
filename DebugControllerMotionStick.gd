extends Node3D

@export var id = 0

func _ready():
	pass

func _process(delta):
	rotation = DsuClient.controllers[id].rotation
	pass
