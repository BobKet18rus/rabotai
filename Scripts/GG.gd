extends CharacterBody2D

@export_enum(
"IDLE: 1",
"MOVE: 2",
"FALL: 3",
"JUMP: 4",
"RING: 5",
"H_ROPE: 6",
"D_ROPE: 7",
"V_ROPE: 8",
"LEDGE: 9",
"WALL: 10",
"SHOOTING: 11"
) var state:int = sm.FALL

@export var gravity:Vector2 = Vector2(0, 80)
@export var jump_force:int = -1000
@export var speed:int = 450
@export var acc:float = 0.5
@export var fr:float = 0.5

@export var money:int = 0
@export var health:int = 100
var dir:int

@export_category("Weapons")
@export var weapons:Array

@onready var jump_timer:Node = $timers/jump_timer
@onready var ring_timer:Node = $timers/ring_timer

var jump_possibility:bool = false
var current_checkpoint_position:Vector2

var death_counter:int = 0

var rot_vector:Vector2

var debug_mode:bool

var Clippy_idle_pos:Vector2

func shange_state(new_state:int):
	state = new_state

func die():#переделаю
	velocity = Vector2.ZERO
	death_counter += 1
	self.position = current_checkpoint_position
	self.state = sm.FALL
	
func time(s):#ВЫЗЫВАТЬ AWAIT
	var timer = get_tree().create_timer(s)
	return timer.timeout
	
func state_machine():
	match state:
		sm.IDLE:
			jump_possibility = true
			idle(1)
			if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
				state = sm.IDLE
			elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				state = sm.MOVE
			if not(is_on_floor()):
				state = sm.FALL
				
			shoot()
			jump(1)
			jump_timer_starting()
			jump_off(17)
		sm.MOVE:
			jump_possibility = true
			move(1,1)
			if not(is_on_floor()):
				state = sm.FALL
				
			shoot()
			jump(1)
			jump_timer_starting()
			jump_off(17)
		sm.FALL:
			if $timers/c_timer.is_stopped():
				jump_possibility = false
			else:
				jump_possibility = true

			jump(1)
			jump_timer_starting()
			gravitation(1)
			move(1, 0.2)
			if is_on_floor():
				state = sm.IDLE
			elif is_on_wall():
				velocity = Vector2.ZERO
				state = sm.WALL
				
		sm.JUMP:
			if jump_timer.is_stopped() or is_on_ceiling() or Input.is_action_just_released("jump"):
				state = sm.FALL
			else:
				jump_possibility = true
				
			if is_on_wall():
				velocity = lerp(velocity, Vector2.ZERO, 0.9)
				state = sm.WALL
			move(1, 0.2)
		sm.RING:
			jump_possibility = true
			if Input.is_action_just_pressed("down"):
				state = sm.FALL
				ring_timer.start()
			ring_timer_starting()
			jump(1)
			jump_timer_starting()
		sm.H_ROPE:
			jump_possibility = true
			if Input.is_action_just_pressed("down") or is_on_ceiling():
				state = sm.FALL
				ring_timer.start()
			move(0.8, 1)
			ring_timer_starting()
			jump(1)
			jump_timer_starting()
		sm.D_ROPE:
			pass
		sm.V_ROPE:
			pass
		sm.LEDGE:
			pass
		sm.WALL:
			jump_possibility = true
			if ($left_ray.is_colliding() or $right_ray.is_colliding()) and not(Input.is_action_pressed("down")):
				gravitation(0.1)
			else:
				gravitation(1)
			jump(0.8)
			wall_jump(10)
			jump_timer_starting()
			if is_on_floor():
				state = sm.IDLE
			elif not(is_on_wall()):
				state = sm.FALL
		sm.SHOOTING:
			idle(1)
			shoot()
#			if $Animator.current_animation == "SHOOTING_LEFT" or "SHOOTING_LEFT":
#				state = sm.SHOOTING
#			else:
#				state = sm.IDLE

func jump_off(l):
	if Input.is_action_just_pressed("down"):
		self.position.y += l
		state = sm.FALL
	
func wall_jump(s_mult):
	if is_on_wall():
		if Input.is_action_just_pressed("jump"):
			if $left_ray.is_colliding():
				velocity.x = lerpf(velocity.x, speed*s_mult, 0.1)
			else:
				velocity.x = lerpf(velocity.x, -speed*s_mult, 0.1)
func debug():
	
	if Input.is_action_just_pressed("debug"):
		match debug_mode:
			true:
				debug_mode = false
				$debug.visible = false
			_:
				debug_mode = true
				$debug.visible = true
		
	$debug/state.text = "STATE: "+str(state)
	$debug/velocity.text = "VELOCITY: "+str(velocity)
	$debug/angle.text = "FLOOR_ANGLE: "+str(rad_to_deg($down_ray.target_position.angle_to(rot_vector)))
	$debug/FPS.text = "FPS: "+str(Engine.get_frames_per_second())
	@warning_ignore("integer_division")
	$debug/mem.text = "MEM: cur: "+str(OS.get_static_memory_usage()/1000000)+", max: "+str(OS.get_static_memory_peak_usage()/1000000)
	$debug/pos.text = "POSITION: "+str(self.position)
	$debug/camera_zoom.text = "CAMERA_ZOOM: "+str($camera.zoom)
	$debug/c_timer.text = "timers: "+str($timers/c_timer.time_left)
	
func jump_timer_starting():
	if Input.is_action_just_pressed("jump"):
		jump_timer.start(0.2)

func ring_timer_starting():
	if Input.is_action_just_pressed("jump"):
		ring_timer.start()
func jump(force_mult:float):
	if Input.is_action_just_pressed("jump") and (jump_possibility == true):########
		jump_timer_starting()
		state = sm.JUMP
		velocity.y += jump_force*force_mult
		
func move(s, a):
	if is_on_floor() and (Input.is_action_pressed("left") and Input.is_action_pressed("right")):
		state = sm.IDLE
	elif Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		idle(1)
	elif state == sm.H_ROPE and not(Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		idle(1)
	elif Input.is_action_pressed('left'):
		velocity.x = lerpf(velocity.x, -speed*s, acc*a)
	elif Input.is_action_pressed("right"):
		velocity.x = lerpf(velocity.x, speed*s, acc*a)
	else:
		if is_on_floor():
			state = sm.IDLE
		
		
func idle(fr_mult):
	velocity.x = lerpf(velocity.x, 0.0, fr*fr_mult)
	
func gravitation(grav_mult:float):
	velocity += gravity*grav_mult


func Clippy():
	if Input.is_action_pressed("LMB"):
		$clippy.position = lerp($clippy.position, self.get_local_mouse_position(), 0.3)
	else:
		$clippy.position = lerp($clippy.position, to_local(self.position), 0.2)
	
func Money_system():
	$CANVAS/HUD/Money.text = "$"+" "+str(money)
	
func shoot():
	if Input.is_action_pressed("LMB"):
		if dir == -1:
			state = sm.SHOOTING
			if not($Animator.is_playing()):
				$Animator.play("SHOOTING_LEFT")
		elif dir == 1:
			state = sm.SHOOTING
			if not($Animator.is_playing()):
				$Animator.play("SHOOTING_RIGHT")
	
func spawn_projectile(ID:int, spawn_coordinates:Vector2, rot:int):
	var new_projectile:Node2D = weapons[ID].instantiate()
	new_projectile.position = self.position + spawn_coordinates
	new_projectile.rotation_degrees = rot
	get_parent().add_child(new_projectile)
	
#####################################################################################
	
func _ready() -> void:
	debug_mode = false
	print(Vector2(270, 0).rotated(deg_to_rad(45)))
	print(Vector2(270, 0).rotated(deg_to_rad(135)))

func _process(_delta):
	debug()
	Money_system()
	Clippy()
	
	if dir == -1:
		$sprite.flip_h = true
	elif dir == 1:
		$sprite.flip_h = false
	
	if Input.is_action_just_pressed("left"):
		dir = -1
	elif Input.is_action_just_pressed("right"):
		dir = 1
	
	if Input.is_action_just_pressed("t1"):
		die()
		
	if $rotate_cast.is_colliding():
		rot_vector = -$rotate_cast.get_collision_normal(0)
	else:
		rot_vector = Vector2.ZERO
	
	if is_on_floor():
		
		$sprite.rotation = lerp_angle($sprite.rotation, $down_ray.target_position.angle_to(rot_vector), 0.3)
#		elif $left_ray.is_colliding():
#			$sprite.rotation = lerp_angle($sprite.rotation, Vector2(1, 2).angle_to(-$down_ray.get_collision_normal()+Vector2(0, 48)), 0.3)
#		elif $right_ray.is_colliding():
#			$sprite.rotation = lerp_angle($sprite.rotation, Vector2(-1, 2).angle_to(-$down_ray.get_collision_normal()+Vector2(0, 48)), 0.3)
	else:
		$sprite.rotation = lerp_angle($sprite.rotation, 0.0, 0.1)
	
@warning_ignore("unused_parameter")
func _physics_process(delta):
	
	var was_on_floor:bool = is_on_floor()
	
	state_machine()
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
	
	if was_on_floor && !is_on_floor() && not(Input.is_action_pressed("jump")):
		$timers/c_timer.start()
