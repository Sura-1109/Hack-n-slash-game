extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var deal_damage_zone = $DealDamageZone

const SPEED = 300.0
const jump_power = -500.0

var attack_type: String
var current_attack: bool
var weapon_equip: bool

var gravity = 900

func _ready():
	Global.playerBody = self
	current_attack = false

func _physics_process(delta: float) -> void:
	var weapon_equip = Global.playerWeaponEquip
	Global.playerDamageZone = deal_damage_zone
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if weapon_equip and !current_attack:
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
	handle_movement_animation(direction)

func handle_movement_animation(dir):
	if !weapon_equip:
		if is_on_floor():
			if !velocity:
				animated_sprite.play("idle")
		if velocity:
			animated_sprite.play("run")
			toggle_flip_sprite(dir)
		elif !is_on_floor():
			animated_sprite.play("fall")

	if weapon_equip:
		if is_on_floor() and !current_attack:
			if !velocity:
				animated_sprite.play("weapon_idle")
		if velocity:
			animated_sprite.play("weapon_run")
			toggle_flip_sprite(dir)
		elif !is_on_floor() and !current_attack:
			animated_sprite.play("weapon_fall")

func toggle_flip_sprite(dir):
	if dir == 1:
		animated_sprite.flip_h = false
		deal_damage_zone.scale.x = -1
	if dir == -1:
		animated_sprite.flip_h = true
		deal_damage_zone.scale.x = 1
		
func handle_attack_animation(attack_type):
	if weapon_equip:
		if current_attack:
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
