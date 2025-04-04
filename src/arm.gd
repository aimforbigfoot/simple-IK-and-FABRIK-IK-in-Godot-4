extends Node2D

@onready var joints = [
	$Marker2D,
	$Marker2D/Marker2D2,
	$Marker2D/Marker2D2/Marker2D3,
	$Marker2D/Marker2D2/Marker2D3/Marker2D4,
]

@export var target : Node2D
var lengths = []
var tolerance = 1.0
var max_iterations = 10

func _ready():
	# Initialize lengths between joints
	for i in range(joints.size() - 1):
		var len = joints[i].global_position.distance_to(joints[i+1].global_position)
		lengths.append(len)

func _process(delta):
	fabrik()
	queue_redraw()

func fabrik():
	var positions = []
	for j in joints:
		positions.append(j.global_position)

	var target_pos = target.global_position
	var base_pos = positions[0]
	var total_length = 0.0
	for len in lengths:
		total_length += len



	# Check if target is reachable
	if base_pos.distance_to(target_pos) > total_length:
		# Stretch towards the target
		for i in range(len(positions) - 1):
			var dir = (target_pos - positions[i]).normalized()
			positions[i+1] = positions[i] + dir * lengths[i]
	else:
		var iter = 0
		var end_effector = positions[-1]
		while end_effector.distance_to(target_pos) > tolerance and iter < max_iterations:
			# Backward pass
			positions[-1] = target_pos
			for i in range(len(positions) - 2, -1, -1):
				var dir = (positions[i] - positions[i+1]).normalized()
				positions[i] = positions[i+1] + dir * lengths[i]

			# Forward pass
			positions[0] = base_pos
			for i in range(0, len(positions) - 1):
				var dir = (positions[i+1] - positions[i]).normalized()
				positions[i+1] = positions[i] + dir * lengths[i]

			end_effector = positions[-1]
			iter += 1

	# Update joint positions and rotations
	for i in range(len(joints)):
		joints[i].global_position = positions[i]
		if i < len(joints) - 1:
			var dir = (positions[i+1] - positions[i]).angle()
			joints[i].rotation = dir


func _draw() -> void:
	for i in range(joints.size() - 1):
		draw_line(
			(joints[i].global_position) - global_position,
			(joints[i+1].global_position) - global_position,
			Color.RED,
			6.0,
			true
		)
