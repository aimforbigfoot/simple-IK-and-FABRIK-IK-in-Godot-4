extends Node2D

@onready var shoulder = $shoulder
@onready var elbow = $shoulder/elbow
@onready var hand = $shoulder/elbow/hand

@onready var shoulder_sprite = $shoulder/shoudlerSprite
@onready var elbow_sprite = $shoulder/elbow/elbowSprite

@export var target: Node2D
@export var flip_elbow: bool = false

# idk how to make it exactly the same size as the sprite so you gotta code them in, ig you can also make these dynamic o..o
@export var upper_length := 200.0
@export var lower_length := 300.0

func _ready():
	# Initialize local positions assuming the bones extend along the positive X-axis.
	elbow.position = Vector2(upper_length, 0)
	hand.position = Vector2(lower_length, 0)

func _process(_delta):
	if target:
		solve_ik(target.global_position)

func solve_ik(target_pos: Vector2):
	var base_pos = shoulder.global_position
	var to_target = target_pos - base_pos
	var d = to_target.length()
	# Clamp d to ensure the target is reachable.
	d = clamp(d, 0.001, upper_length + lower_length)

	# θ: the angle from the shoulder to the target.
	var theta = to_target.angle()

	# Compute the angle (α) between the upper arm and the line from the shoulder to the target.
	var angleA = acos(clamp((upper_length * upper_length + d * d - lower_length * lower_length) / (2 * upper_length * d), -1.0, 1.0))

	# Choose the shoulder rotation based on whether we flip the elbow or not.
	var shoulder_angle = 0.0
	if flip_elbow:
		shoulder_angle = theta + angleA
	else:
		shoulder_angle = theta - angleA

	# Compute the internal elbow angle using the cosine law.
	var internal_elbow = acos(clamp((upper_length * upper_length + lower_length * lower_length - d * d) / (2 * upper_length * lower_length), -1.0, 1.0))
	# The external elbow angle (for bending) is the supplement.
	var elbow_angle = PI - internal_elbow

	# Calculate the global position of the elbow.
	var elbow_global = base_pos + Vector2(upper_length, 0).rotated(shoulder_angle)
	elbow.global_position = elbow_global

	# Determine the angle for the lower arm (hand) based on flip.
	var hand_angle = 0.0
	if flip_elbow:
		hand_angle = shoulder_angle - elbow_angle
	else:
		hand_angle = shoulder_angle + elbow_angle

	# Calculate the global position of the hand.
	var hand_global = elbow_global + Vector2(lower_length, 0).rotated(hand_angle)
	hand.global_position = hand_global

	# --- Rotate the Joint Sprites ---
	# Rotate the shoulder sprite to match the upper arm's direction.
	if shoulder_sprite:
		shoulder_sprite.global_rotation = shoulder_angle

	# Rotate the elbow sprite based on the lower arm's orientation.
	if elbow_sprite:
		var elbow_sprite_angle = 0.0
		if flip_elbow:
			elbow_sprite_angle = shoulder_angle - elbow_angle
		else:
			elbow_sprite_angle = shoulder_angle + elbow_angle
		elbow_sprite.global_rotation = elbow_sprite_angle
