extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var label: Label = $Label

enum STATE {
	FALL,
	IDLE,
	JUMP,
	RUN,
	TURN_AROUND
}

var direction
var player_state = STATE.IDLE
var coyote_timer = 0.0
var jump_buffer_timer = 0
var jumped = false


const COYOTE_TIME = 0.1
const JUMP_BUFFER = 0.1
const MAX_SPEED = 300
const JUMP_VELOCITY = -400.0
const ACC = 1200 
const GRAVITY = 1500
const JUMP_GRAVITY = 1000


func _process(delta: float) -> void:
	label.text = str(player_state)
	print("State: ", player_state," D: ",direction, " V: ", velocity)
	
	handle_player_state()
	handle_input()
	handle_animation()

func _physics_process(delta: float) -> void:
	handle_movement(delta)

func handle_movement(delta):
	#coyote time
	if is_on_floor():
		jumped = false
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
		coyote_timer = clamp(coyote_timer, 0, COYOTE_TIME)
	
	#Jump Buffering
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		jump_buffer_timer = clamp(jump_buffer_timer, 0, JUMP_BUFFER)
	
	#Left and right movement
	if direction != 0:
		velocity.x = velocity.x + (direction * ACC) * delta
	else:
		if velocity.x > 0:
			velocity.x = velocity.x - (ACC * delta)
			velocity.x = clamp(velocity.x, 0, MAX_SPEED)
		else:
			velocity.x = velocity.x + (ACC * delta)
			velocity.x = clamp(velocity.x, -MAX_SPEED, 0)
	
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	
	#Jumping
	if (coyote_timer > 0 or is_on_floor()) and jump_buffer_timer > 0 and !jumped:
		jumped = true
		jump_buffer_timer = 0
		velocity.y = JUMP_VELOCITY
	#Gravity
	if not is_on_floor():
		if velocity.y < 0:
			velocity.y += JUMP_GRAVITY * delta
		else:
			velocity.y += GRAVITY * delta
		
	velocity.y = clamp(velocity.y, JUMP_VELOCITY, MAX_SPEED)
	
	
	move_and_slide()

func handle_player_state():
	#Define player state
	if is_on_floor():
		if velocity == Vector2(0, 0) and direction == 0:
			player_state = STATE.IDLE
		elif velocity.x !=0 and (direction < 0 and velocity.x < 0 or direction > 0 and velocity.x > 0):
			player_state = STATE.RUN
		elif direction != 0 and sign(direction) != sign(velocity.x):
			player_state = STATE.TURN_AROUND
	else:
		if velocity.y < 0 :
			player_state = STATE.JUMP
		elif velocity.y > 0 :
			player_state = STATE.FALL
	
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false


func handle_input():
	#Left and Right
	direction = Input.get_axis("A", "D")
	
	#Jump
	if Input.is_action_pressed("W"):
		jump_buffer_timer = JUMP_BUFFER


func handle_animation():
	
	
	#Match animation
	match player_state:
		STATE.IDLE: 
			sprite.play("Idle")
		STATE.RUN:
			sprite.play("Run")
		STATE.TURN_AROUND:
			sprite.play("Turn Around")
		STATE.JUMP:
			sprite.play("Jump")
		STATE.FALL:
			sprite.play("Fall")
