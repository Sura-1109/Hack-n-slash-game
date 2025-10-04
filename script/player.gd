extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var deal_damage_zone = $DealDamageZone

const SPEED = 300.0
const jump_power = -500.0

var attack_type: String
var current_attack: bool
var weapon_equip: bool
var gravity = 900

var health = 100
var health_max = 100
var health_min = 0
var dead = false
var taking_damage = false
var is_invincible = false

func _ready():
	Global.playerBody = self
	current_attack = false

func _physics_process(delta: float) -> void:
	weapon_equip = Global.playerWeaponEquip
	Global.playerDamageZone = deal_damage_zone
	
	if dead:
		velocity.x = 0
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power
		
	var direction := Input.get_axis("left", "right")
	
	# Only allow movement input if not attacking or taking damage
	if !current_attack and !taking_damage:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Handle attacks
	if weapon_equip and !current_attack and !taking_damage:
		if Input.is_action_just_pressed("left_mouse") or Input.is_action_just_pressed("right_mouse"):
			current_attack = true
			if Input.is_action_just_pressed("left_mouse") and is_on_floor():
				attack_type = "single"	
			elif Input.is_action_just_pressed("right_mouse") and is_on_floor():
				attack_type = "double"
			else:
				attack_type = "air"
			set_damage(attack_type)
			handle_attack_animation(attack_type)
				
	move_and_slide()
	
	# Only update movement animations if not attacking or taking damage
	if !current_attack and !taking_damage:
		handle_movement_animation(direction)

func handle_movement_animation(dir):
	if !weapon_equip:
		if is_on_floor():
			if velocity.x == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
				toggle_flip_sprite(dir)
		else:
			animated_sprite.play("fall")
	else:  # weapon_equip is true
		if is_on_floor():
			if velocity.x == 0:
				animated_sprite.play("weapon_idle")
			else:
				animated_sprite.play("weapon_run")
				toggle_flip_sprite(dir)
		else:
			animated_sprite.play("weapon_fall")
	
	# Update sprite direction even during movement
	if dir != 0:
		toggle_flip_sprite(dir)

func toggle_flip_sprite(dir):
	if dir == 1:
		animated_sprite.flip_h = false
		deal_damage_zone.scale.x = -1
	elif dir == -1:
		animated_sprite.flip_h = true
		deal_damage_zone.scale.x = 1
		
func handle_attack_animation(attack_type):
	if weapon_equip and current_attack:
		var animation = str(attack_type, "_attack")
		animated_sprite.play(animation)
		toggle_damage_collision(attack_type)

func toggle_damage_collision(attack_type):
	var damage_zone_collision = deal_damage_zone.get_node("CollisionShape2D")
	var wait_time: float
	
	if attack_type == "air":
		wait_time = 0.6
	elif attack_type == "single":
		wait_time = 0.4
	elif attack_type == "double":
		wait_time = 0.7
	
	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true

func _on_animated_sprite_2d_animation_finished() -> void:
	current_attack = false

func set_damage(attack_type):
	var current_damage_to_deal: int
	
	if attack_type == "single":
		current_damage_to_deal = 8
	elif attack_type == "double":
		current_damage_to_deal = 16
	elif attack_type == "air":
		current_damage_to_deal = 20
		
	Global.playerDamageAmount = current_damage_to_deal

# ========== DAMAGE HANDLING ==========

func _on_player_hitbox_area_entered(area: Area2D) -> void:
	if area == Global.batDamageZone and !is_invincible:
		var damage = Global.batDamageAmount
		take_damage(damage)

func take_damage(damage):
	if is_invincible or dead:
		return
		
	health -= damage
	taking_damage = true
	is_invincible = true
	
	if health <= 0:
		health = 0
		dead = true
		handle_death()
	else:
		handle_hurt()
	
	print("Player current health is ", health)

func handle_hurt():
	animated_sprite.play("hurt")  # Make sure you have this animation
	
	# Brief invincibility after getting hit
	await get_tree().create_timer(0.8).timeout
	taking_damage = false
	is_invincible = false

func handle_death():
	animated_sprite.play("death")  # Make sure you have this animation
	
	# Disable collision with enemies
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, false)
	
	# Optional: reload scene or show game over
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()  # or change to game over scene
