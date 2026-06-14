extends CharacterBody2D

const SPEED = 80

var input_dir: Vector2
var attackable_enemies: Array = []

var lastDirection = 'down'

@export var is_attacking := false
@export var health = 10

func _physics_process(_delta):
	# keyboard input
	input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir.normalized() * SPEED

	if (is_attacking == true):
		return

	# moves node and detects collision objects
	move_and_slide()
	
	# animation
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
	if ('sword' in $AnimatedSprite2D.animation):
		is_attacking = false

func _on_attack_range_entered(body: Node2D) -> void:
	if ('Enemy' in body.name or 'CharacterBody2D' in body.name):
		attackable_enemies.push_back(body)

func _on_attack_range_exited(body: Node2D) -> void:
	attackable_enemies.erase(body)
	
func attack():
	for enemy in attackable_enemies:
		if (enemy.dying == false):
			enemy.take_damage()
