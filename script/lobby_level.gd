extends Node2D

@onready var player_camera = $player/Camera2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_camera.enabled = false
	Global.playerWeaponEquip = false
	Global.playerAlive = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.gameStarted = true 
		get_tree().change_scene_to_file("res://scene/stage_level.tscn")
