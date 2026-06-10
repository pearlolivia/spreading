extends Node2D

const SPAWN_OFFSET = 175
var rng := RandomNumberGenerator.new()

@onready var player: CharacterBody2D = $Player
@onready var enemy_scene = preload("res://scenes/enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#print(player.is_attacking)

func _on_spawn_timer_timeout() -> void:
	var spawnerPosition = $Enemies/Spawner.position
	var random_x = rng.randi_range(spawnerPosition.x - SPAWN_OFFSET, spawnerPosition.x + SPAWN_OFFSET)
	var random_y = rng.randi_range(spawnerPosition.y - SPAWN_OFFSET, spawnerPosition.y + SPAWN_OFFSET)
	var enemy = enemy_scene.instantiate()
	
	var enemy_group = $Enemies.get_groups()
	#if (enemy_group.size() > 0):
	print(get_tree().get_nodes_in_group('enemies').size())
	enemy.player = player
	enemy.name = "Enemy_"
	add_child(enemy)
	enemy.position = Vector2(random_x, random_y)
	$Enemies.add_to_group("enemies")
