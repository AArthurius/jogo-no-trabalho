extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite

var direction

const MAX_SPEED = 300
const JUMP_VELOCITY = -400.0
const ACC = 1200 

func _process(delta: float) -> void:
	handle_animation()

func _physics_process(delta: float) -> void:
	handle_movement(delta)

func handle_movement(delta):
	#Left and Right
	direction = Input.get_axis("A", "D")
	if direction != 0:
		velocity.x = velocity.x + (direction * ACC) * delta
	else:
		velocity.x = move_toward(velocity.x, 0, ACC * delta)
	velocity.x = clamp(velocity.x, -300, MAX_SPEED)
	
	#Jumping
	if is_on_floor() and Input.is_action_pressed("Space"):
		velocity.y = -400
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, 400, ACC * delta)
	
	
	move_and_slide()

func handle_animation():
	#Define player state
	var player_state
	
	if velocity == Vector2(0, 0):
		player_state = "Idle"
	elif velocity.length() > 0:
		player_state = "Run"
	#elif direction > velocity.x % 1 (não funciona):
		pass
	
	
	#Match animation
	match player_state:
		"Idle": 
			sprite.play("Idle")
		"Run":
			sprite.play("Run")
