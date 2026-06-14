extends CharacterBody2D

const SPEED: int = 20
const DIRECTIONAL_CHANGE: float = 0.3

var health := 2
var knockback = 5

var spawning := true
var dying := false
var facingDirection = 'down'

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var player: CharacterBody2D

func _ready() -> void:
	$AnimatedSprite2D.play("grow")

func _physics_process(delta):
	if (player and spawning == false and dying == false):
		navigation_agent.target_position = player.global_position
		var direction = global_position.direction_to(navigation_agent.get_next_path_position())
		velocity = direction * SPEED
		move_and_slide()
		
		if (direction.x < -DIRECTIONAL_CHANGE):
			facingDirection = 'left'
		elif (direction.x > DIRECTIONAL_CHANGE):
			facingDirection = 'right'
		elif (direction.y < -DIRECTIONAL_CHANGE):
			facingDirection = 'up'
		elif (direction.y > DIRECTIONAL_CHANGE):
			facingDirection = 'down'
		
		if (spawning == false and dying == false):
			if (facingDirection == 'left'):
				$AnimatedSprite2D.play("walk_right")
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.play("walk_" + facingDirection)
				$AnimatedSprite2D.flip_h = false

func _on_animation_finished() -> void:
	if ($AnimatedSprite2D.animation == 'grow'):
		spawning = false
	if ('damage' in $AnimatedSprite2D.animation):
		dying = false
	if ($AnimatedSprite2D.animation == 'die'):
		queue_free()

func take_damage():
	var new_health = health - 1
	health = new_health
	dying = true
	if (new_health <= 0):
		if (facingDirection == 'left'):
			$AnimatedSprite2D.play("damage_right")
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.play("damage_" + facingDirection)
			$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play('die')
	else:
		self.position = Vector2(self.position.x + knockback, self.position.y + knockback)
		move_and_slide()
		if (facingDirection == 'left'):
			$AnimatedSprite2D.play("damage_right")
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.play("damage_" + facingDirection)
			$AnimatedSprite2D.flip_h = false
