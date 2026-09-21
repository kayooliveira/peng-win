extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $Anim
@onready var die_sfx: AudioStreamPlayer = $Die
@onready var jump_sfx: AudioStreamPlayer = $Jump
@onready var ceiling_check: RayCast2D = $CeilingCheck
@onready var camera: Camera2D = $Camera2D

@export var collision: CollisionShape2D

const SPEED := 85.0
const JUMP_VELOCITY := -250.0
const HURT_DURATION := 1.5
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.1
const IFRAME_DURATION := 1.0
const SHAKE_DECAY := 12.0

enum PlayerState {
	IDLE,
	WALK,
	CROUCH,
	JUMP,
	FALLING,
	FLYING,
	HURT,
	DEAD,
	DANCING,
}

@export var coins := 0
@export var lifes := 5

var state := PlayerState.IDLE
var has_jumped := false

var original_height: float
var original_position_y: float

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_on_floor := false
var invulnerable := false
var iframe_timer := 0.0
var shake_strength := 0.0


func _ready() -> void:
	change_state(PlayerState.IDLE)
	was_on_floor = is_on_floor()
	if collision and collision.shape:
		original_position_y = collision.position.y
		if "height" in collision.shape:
			original_height = collision.shape.height
		elif "size" in collision.shape:
			original_height = collision.shape.size.y


func _physics_process(delta: float) -> void:
	_update_camera_shake(delta)
	_update_iframes(delta)

	if state == PlayerState.HURT or state == PlayerState.DANCING or state == PlayerState.DEAD:
		return

	handle_movement(delta)
	update_state()


func handle_movement(delta: float) -> void:
	var direction := Input.get_axis("left", "right")

	var current_speed = SPEED
	if state == PlayerState.CROUCH:
		current_speed = SPEED * 0.5

	if direction:
		velocity.x = direction * current_speed
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	if is_on_floor():
		coyote_timer = COYOTE_TIME
		has_jumped = false
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	if state != PlayerState.CROUCH:
		_try_jump()

	if not is_on_floor():
		if Input.is_action_pressed("jump") and velocity.y >= 0:
			velocity.y += get_gravity().y * 0.3 * delta
			velocity.y = min(velocity.y, 60.0)
		else:
			velocity.y += get_gravity().y * delta

	var fall_speed := velocity.y
	move_and_slide()

	if is_on_floor() and not was_on_floor:
		_play_land_squash(fall_speed)
		coyote_timer = COYOTE_TIME
		has_jumped = false
		if state != PlayerState.CROUCH:
			_try_jump()

	was_on_floor = is_on_floor()


func _try_jump() -> void:
	if jump_buffer_timer <= 0.0:
		return

	var can_ground_jump := is_on_floor() or coyote_timer > 0.0
	if can_ground_jump:
		_do_jump()
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		has_jumped = false
	elif not has_jumped:
		_do_jump()
		has_jumped = true
		jump_buffer_timer = 0.0


func _do_jump() -> void:
	velocity.y = JUMP_VELOCITY
	jump_sfx.pitch_scale = randf_range(0.5, 1.0)
	jump_sfx.play()


func update_state() -> void:
	if not is_on_floor():
		if Input.is_action_pressed("jump") and velocity.y >= 0:
			change_state(PlayerState.FLYING)
		elif velocity.y < 0:
			change_state(PlayerState.JUMP)
		else:
			change_state(PlayerState.FALLING)
		return

	var has_ceiling: bool = ceiling_check.is_colliding()

	if Input.is_action_pressed("crouch") or (state == PlayerState.CROUCH and has_ceiling):
		if state != PlayerState.CROUCH:
			position.y += 1.0
		change_state(PlayerState.CROUCH)
		return

	if velocity.x != 0:
		change_state(PlayerState.WALK)
		return

	if state != PlayerState.DANCING:
		change_state(PlayerState.IDLE)


func change_state(new_state: PlayerState) -> void:
	if state == new_state:
		return

	if state == PlayerState.CROUCH and collision and collision.shape:
		collision.position.y = original_position_y
		if "height" in collision.shape:
			collision.shape.height = original_height
		elif "size" in collision.shape:
			collision.shape.size.y = original_height

	state = new_state

	match state:
		PlayerState.IDLE:
			anim.play("idle")
		PlayerState.WALK:
			anim.play("walk")
		PlayerState.CROUCH:
			anim.play("crouch")
			if collision and collision.shape:
				var target_crouch_height = 10.0
				collision.position.y = original_position_y + ((original_height - target_crouch_height) / 2)
				if "height" in collision.shape:
					collision.shape.height = target_crouch_height
				elif "size" in collision.shape:
					collision.shape.size.y = target_crouch_height
		PlayerState.JUMP:
			anim.play("jump")
		PlayerState.FALLING:
			anim.play("falling")
		PlayerState.FLYING:
			anim.play("flying")
		PlayerState.HURT:
			anim.play("hurt")
		PlayerState.DEAD:
			anim.play("dead")
		PlayerState.DANCING:
			anim.play("victory")


func is_invulnerable() -> bool:
	return invulnerable or state == PlayerState.HURT or state == PlayerState.DEAD


func start_iframes(duration: float = IFRAME_DURATION) -> void:
	invulnerable = true
	iframe_timer = duration


func shake_camera(amount: float = 3.0) -> void:
	shake_strength = maxf(shake_strength, amount)


func die() -> void:
	if state == PlayerState.DEAD or state == PlayerState.HURT:
		return

	#if lifes <= 1:
		#print("Game Over")
		#change_state(PlayerState.DEAD)
		#return
	#else:
		#lifes -= 1

	change_state(PlayerState.HURT)
	velocity = Vector2.ZERO
	die_sfx.play()
	shake_camera(4.0)

	await get_tree().create_timer(HURT_DURATION).timeout

	change_state(PlayerState.IDLE)


func _play_land_squash(fall_speed: float) -> void:
	if fall_speed < 80.0:
		return

	var intensity := clampf(fall_speed / 300.0, 0.25, 1.0)
	var squash := Vector2(1.0 + 0.18 * intensity, 1.0 - 0.22 * intensity)
	anim.scale = squash

	var tween := create_tween()
	tween.tween_property(anim, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_iframes(delta: float) -> void:
	if not invulnerable:
		anim.modulate.a = 1.0
		return

	iframe_timer -= delta
	if iframe_timer <= 0.0:
		invulnerable = false
		anim.modulate.a = 1.0
		return

	if state != PlayerState.HURT:
		anim.modulate.a = 0.35 if int(Time.get_ticks_msec() / 80) % 2 == 0 else 1.0


func _update_camera_shake(delta: float) -> void:
	if shake_strength > 0.05:
		camera.offset = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * shake_strength
		shake_strength = lerpf(shake_strength, 0.0, SHAKE_DECAY * delta)
	else:
		shake_strength = 0.0
		camera.offset = Vector2.ZERO
