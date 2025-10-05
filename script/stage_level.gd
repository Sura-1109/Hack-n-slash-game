extends Node2D

@onready var player_camera = $player/Camera2D

func _ready() -> void:
	player_camera.enabled = true
	Global.playerWeaponEquip = true
	Global.playerAlive = true

func _process(delta):
	if !Global.playerAlive: 
		transition_to_lobby()

func transition_to_lobby():
	# Wait for death animation
	await get_tree().create_timer(2.0).timeout
	Global.gameStarted = false
	get_tree().change_scene_to_file("res://scene/lobby_level.tscn")
