extends CharacterBody2D

const SPEED = 80
const MAX_HEALTH = 10
const knockback_strength = 175
const min_knockback = 1.1

var input_dir: Vector2
var attackable_enemies: Array = []
var knockback: Vector2

var lastDirection = 'down'
var dying := false

@export var is_attacking := false
@export var health = MAX_HEALTH

var is_dead

signal pause()
signal reset_level()

func _physics_process(_delta):
	is_dead = health <= 0
	# player loses life
	if (is_dead):
		if (dying == true):
			$AnimatedSprite2D.play("dead")
			$HeartsAnimation/LifeLost.visible = true
			$HeartsAnimation/LifeLost.play("default")
			$"../Sounds/LifeLost".play()
			dying = false
		return
		
	# keyboard input
	input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir.normalized() * SPEED
	
	# move during enemy collision (knockback)
	if (knockback.length() > min_knockback):
		knockback /= min_knockback
		velocity = knockback
		move_and_slide()
		return
		
	# prevent movement whilst attacking
	if (is_attacking == true):
		return
		
	# moves node and detects collision objects
	move_and_slide()
	
	# animations
	if (Input.is_action_pressed("attack") and is_attacking == false):
		is_attacking = true
		attack()
		if (lastDirection == 'left'):
			$AnimatedSprite2D.play("sword_right")
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.play("sword_" + lastDirection)
			$AnimatedSprite2D.flip_h = false
	elif (Input.is_action_pressed("down")):
		$AnimatedSprite2D.play("walk_down")
		lastDirection = 'down'
	elif (Input.is_action_pressed("up")):
		$AnimatedSprite2D.play("walk_up")
		lastDirection = 'up'
	elif (Input.is_action_pressed("left")):
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("walk_right")
		lastDirection = 'left'
	elif (Input.is_action_pressed("right")):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walk_right")
		lastDirection = 'right'
	else:
		if (lastDirection == 'up'):
			$AnimatedSprite2D.play("idle_up")
		elif (lastDirection == 'down'):
			$AnimatedSprite2D.play("idle_down")
		elif (lastDirection == 'left'):
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("idle_right")
		elif (lastDirection == 'right'):
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("idle_right")

func _on_animation_finished() -> void:
	# dying/ damage period over once dead
	if ($AnimatedSprite2D.animation == 'damage' and is_dead == true):
		dying = false
		return
		
	if ($AnimatedSprite2D.animation == "dead"):
		# LOSE A LIFE & reset stats
		Global.LIVES -= 1
		await get_tree().create_timer(1).timeout
		reset_player()
		return
		
	if ('sword' in $AnimatedSprite2D.animation):
		is_attacking = false
	# dying period over & reset knockback
	if ('damage' in $AnimatedSprite2D.animation):
		knockback = Vector2(0, 0)
		dying = false

func _on_attack_range_entered(body: Node2D) -> void:
	if ('Enemy' in body.name or 'CharacterBody2D' in body.name):
		attackable_enemies.push_back(body)

func _on_attack_range_exited(body: Node2D) -> void:
	attackable_enemies.erase(body)

func get_opposite_direction(dir: String):
	var oppositeDir
	match (dir):
		'left':
			oppositeDir = 'right'
		'right':
			oppositeDir = 'left'
		'up':
			oppositeDir = 'down'
		'down':
			oppositeDir = 'up'
	
	return oppositeDir
	
func attack():
	for enemy in attackable_enemies:
		# check player facing enemy
		var isCorrectDir = enemy.facingDirection == get_opposite_direction(lastDirection)
		if (enemy.dying == false and isCorrectDir == true):
			enemy.take_damage()

func _on_hitbox_entered(body: Node2D) -> void:
	# take damage
	if (('Enemy' in body.name or 'CharacterBody2D' in body.name) and is_dead == false):
		health -= 1
		dying = true
		is_attacking = false
		
		# apply knockback
		knockback = global_position.direction_to(body.global_position) * knockback_strength * -1
		
		if (lastDirection == 'left'):
			$AnimatedSprite2D.play("damage_right")
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.play("damage_" + lastDirection)

func reset_player():
	is_dead = false
	health = MAX_HEALTH
	lastDirection = 'down'
	is_attacking = false
	attackable_enemies = []
	$HeartsAnimation/LifeLost.visible = false
	$AnimatedSprite2D.play("idle_down")
	reset_level.emit()
