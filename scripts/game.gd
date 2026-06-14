extends Node2D

const SPAWN_OFFSET = 150
var rng := RandomNumberGenerator.new()

@onready var player: CharacterBody2D = $Player
@onready var player_spawn_point = $EnemyControls/Spawner
@onready var enemy_scene = preload("res://scenes/enemy.tscn")
@onready var spawn_patch_scene = preload("res://scenes/spawn_patch.tscn")

func _ready() -> void:
	# spawn plants
	pass

func _process(delta: float) -> void:
	$Player/HUD/Health/HealthBar.value = player.health

func _on_spawn_timer_timeout() -> void:
	#spawn enemies
	var spawnerPosition = $EnemyControls/Spawner.position
	var random_x = rng.randi_range(spawnerPosition.x - SPAWN_OFFSET, spawnerPosition.x + SPAWN_OFFSET)
	var random_y = rng.randi_range(spawnerPosition.y - SPAWN_OFFSET, spawnerPosition.y + SPAWN_OFFSET)
	var enemy = enemy_scene.instantiate()
	var patch = spawn_patch_scene.instantiate()
	
	enemy.player = player
	$Enemies.add_child(enemy)
	enemy.position = Vector2(random_x, random_y)
	
	await get_tree().create_timer(0.5).timeout
	$SpawnPatches.add_child(patch)
	patch.position = Vector2(random_x, random_y + 8)

func delete_enemies():
	for enemy in $Enemies.get_children():
		enemy.queue_free()

func _on_player_reset_level() -> void:
	# remove enemies, reset player spawn point & restart enemy spawn timer
	delete_enemies()
	player.global_position = player_spawn_point.global_position
	$EnemyControls/SpawnTimer.wait_time = 5
	$EnemyControls/SpawnTimer.start()

func _on_player_pause() -> void:
	$EnemyControls/SpawnTimer.stop()
