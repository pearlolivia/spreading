extends CharacterBody2D

const SPEED: int = 20
const DIRECTIONAL_CHANGE: float = 0.3

var spawning := true
var dying := false
var facingDirection = 'down'

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var player: CharacterBody2D

func _ready() -> void:
	$AnimatedSprite2D.play("grow")

func _physics_process(delta):
	if (player and spawning == false):
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
