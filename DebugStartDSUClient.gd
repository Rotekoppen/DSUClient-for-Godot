extends Node

func _ready():
	DsuClient.start_polling()
	pass

func _process(delta):
	pass
