extends KinematicBody2D

var rng = RandomNumberGenerator.new()
var bullet_scene = preload("res://scenes/bullet.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")

export var speed : int = 500
export var attack_speed : float = 15
export var attack_spread : float = .1

var health : int = 100
var attack_cur : float = -1

var main : Node2D

func _ready():
	main = get_parent()
	rng.randomize()
	
func _input(event):
	if event.is_action_pressed("spawn"):
		var enemy = enemy_scene.instance()
		enemy.position = Vector2(600, 250)
		enemy.add_to_group("enemies")
		main.add_child(enemy)

func _physics_process(delta):
	if attack_cur >= 0:
		attack_cur += delta
		if attack_cur > 1/attack_speed:
			attack_cur = -1
			
	if attack_cur == -1 && Input.is_action_pressed("shoot"):
		var bullet = bullet_scene.instance()
		var mouse_pos = get_global_mouse_position()
		var angle = (mouse_pos - position).angle()
		bullet.rotation = angle + PI/2 + rng.randf_range(-attack_spread/2, attack_spread/2)
		bullet.position = position
		bullet.group = "enemies"
		bullet.collision_mask = 5 #walls and enemies
		main.add_child(bullet)
		attack_cur = 0
		
	var move : Vector2 = lrud() * speed * delta
	var collision = move_and_collide(move)
	if collision:
		move_and_collide(collision.remainder.slide(collision.normal))
	
func lrud() -> Vector2:
	var input : Vector2 = Vector2.ZERO
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	if Input.is_action_pressed("up"):
		input.y -= 1
	if Input.is_action_pressed('down'):
		input.y += 1
	return input.normalized()

func hurt(damage):
	health -= damage
	$health_bar.value = health
	if health <= 0:
		queue_free()


#
#func _init():
#	var HurtTimer = Timer.new()
#	add_child(HurtTimer)
#	HurtTimer.autostart = true
#	HurtTimer.wait_time = 1
#	HurtTimer.connect("timeout", self, "hurt_time")
#
#func _ready():
#	rng.randomize()
#
#func hurt_time():
#	hurt(rng.randi_range(0, 30))
