extends Node2D

const SPAWN_OFFSET = 150
const SPAWN_RATE =  0.8
var enemy_timeout = 5 #seconds
var rng := RandomNumberGenerator.new()

@onready var player: CharacterBody2D = $Player
@onready var player_spawn_point = $EnemyControls/Spawner
@onready var navigation_agent = $NavigationRegion2D
@onready var plant_nav_agent = $PlantNavRegion
@onready var enemy_spawn_timer = $EnemyControls/SpawnTimer
@onready var wave_timer = $Player/HUD/Wave/WaveTimer
@onready var plants = $Plants
@onready var score = $Player/HUD/Score/HBoxContainer/Score

@onready var enemy_scene = preload("res://scenes/enemy.tscn")
@onready var spawn_patch_scene = preload("res://scenes/spawn_patch.tscn")
@onready var plant_scene = preload("res://scenes/plant.tscn")

var plant_files: Array # textures
var _plant_dir := DirAccess.open("res://assets/plants/")

func _init():
	# get plant sprites
	for _file: String in _plant_dir.get_files():
		if (_file.get_extension() == "png" or _file.get_extension() == 'import'):
			plant_files.push_back("res://assets/plants/" + _file.replace('.import', ''))
			
func _ready() -> void:
	enemy_spawn_timer.wait_time = enemy_timeout
	
	# spawn plants
	await get_tree().create_timer(0.2).timeout
	for i in range(Global.TOTAL_PLANTS):
		var plant = plant_scene.instantiate()
		var spawnerPosition = NavigationServer2D.region_get_random_point(plant_nav_agent.get_rid(), 1, false)
		var plant_idx = rng.randi_range(0, plant_files.size() - 1)
		var texture = load(plant_files[plant_idx])
		$Plants.add_child(plant)
		plant.get_child(0).texture = texture
		plant.position = Vector2(spawnerPosition.x, spawnerPosition.y)

func _process(delta: float) -> void:
	$Player/HUD/Health/HealthBar.value = player.health
	score.text = str(Global.SCORE)

func _on_spawn_timer_timeout() -> void:
	#spawn enemies
	var spawnerPosition = NavigationServer2D.region_get_random_point(navigation_agent.get_rid(), 1, false)
	var enemy = enemy_scene.instantiate()
	var patch = spawn_patch_scene.instantiate()
	
	enemy.player = player
	$Enemies.add_child(enemy)
	enemy.position = Vector2(spawnerPosition.x, spawnerPosition.y)
	
	# if spawns near plant - destroy plant
	var plant_scenes = plants.get_children()
	for plant in plant_scenes:
		var distance = plant.position.distance_to(enemy.position)
		if (distance < 8):
			Global.PLANTS_DESTROYED += 1
			plant.queue_free()
	
	await get_tree().create_timer(0.5).timeout
	$Map/SpawnPatches.add_child(patch)
	patch.position = Vector2(spawnerPosition.x, spawnerPosition.y + 8)

func delete_enemies():
	for enemy in $Enemies.get_children():
		enemy.queue_free()

func _on_player_reset_level() -> void:
	# remove enemies
	delete_enemies()
	
	# reset player spawn point
	player.global_position = player_spawn_point.global_position
	
	# restart timers
	wave_timer.start(Global.WAVE_TIME)
	enemy_spawn_timer.start()

func _on_player_pause() -> void:
	enemy_spawn_timer.stop()

func _on_wave_timer_timeout() -> void:
	Global.WAVE += 1
	# increase enemy spawn rate
	enemy_timeout = enemy_timeout * SPAWN_RATE
	enemy_spawn_timer.wait_time = enemy_timeout
