extends CharacterBody2D

const SPEED = 20
const DIRECTIONAL_CHANGE: float = 0.3
const knockback_strength = 125
const min_knockback = 1.1

var knockback : Vector2

var health := 2
var spawning := true
@export var dying := false
@export var facingDirection = 'down'

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var player: CharacterBody2D

func _ready() -> void:
	$AnimatedSprite2D.play("grow")

func _physics_process(delta):
	# move during attack (knockback)
	if (knockback.length() > min_knockback):
		knockback /= min_knockback
		velocity = knockback
		move_and_slide()
		return
		
	if (player and spawning == false and dying == false):
		navigation_agent.target_position = player.global_position
		var direction = global_position.direction_to(navigation_agent.get_next_path_position())
		velocity = direction * SPEED
		move_and_slide()
		
		self.z_index = 2
		if (direction.x < -DIRECTIONAL_CHANGE):
			facingDirection = 'left'
		elif (direction.x > DIRECTIONAL_CHANGE):
			facingDirection = 'right'
		elif (direction.y < -DIRECTIONAL_CHANGE):
			facingDirection = 'up'
		elif (direction.y > DIRECTIONAL_CHANGE):
			facingDirection = 'down'
			self.z_index = 0
		
		if (spawning == false and dying == false):
			if (facingDirection == 'left'):
				$AnimatedSprite2D.play("walk_right")
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.play("walk_" + facingDirection)
				$AnimatedSprite2D.flip_h = false

func _on_animation_finished() -> void:
	if ($AnimatedSprite2D.animation == 'die'):
		Global.SCORE += 10
		queue_free()
		return
	
	if (health <= 0):
		$AnimatedSprite2D.play("die")
		return
		
	if ($AnimatedSprite2D.animation == 'grow'):
		spawning = false
	if ('damage' in $AnimatedSprite2D.animation and health > 0):
		dying = false
		
func take_damage():
	var new_health = health - 1
	health = new_health
	dying = true
	
	# apply knockback
	knockback = global_position.direction_to(player.global_position) * knockback_strength * -1
	
	if (facingDirection == 'left'):
		$AnimatedSprite2D.play("damage_right")
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.play("damage_" + facingDirection)
		$AnimatedSprite2D.flip_h = false
			
		
