class_name Cover
extends MeshInstance3D

var obstacles = {"x_pos": false, "x_neg": false, "z_pos": false, "z_neg": false}

# Massive if block, maybe a bad way to do it
func peek_direction_from_position(target_position: Vector3) -> Vector3:
	if position.distance_to(target_position) < 1: # If the target position is too close it is not blocked by cover
		return Vector3.ZERO
	if position.x > target_position.x and position.z > target_position.z: # Right Quadrant
		if obstacles["x_neg"] and obstacles["z_neg"]: # This means there are two obstacles completely blocking view of the target
			return Vector3.ZERO
		elif obstacles["x_neg"]: # One obstacle, peek in the negative z direction
			return Vector3(0, 0, -1)
		elif obstacles["z_neg"]: # One obstacle, peek in the negative x direction
			return Vector3(-1, 0, 0)
		return Vector3.ZERO # If unblocked, return no direction
	elif position.x > target_position.x and position.z < target_position.z: # Top Quadrant
		if obstacles["x_neg"] and obstacles["z_pos"]: # This means there are two obstacles completely blocking view of the target
			return Vector3.ZERO
		elif obstacles["x_neg"]: # One obstacle, peek in the positive z direction
			return Vector3(0, 0, 1)
		elif obstacles["z_pos"]: # One obstacle, peek in the negative x direction
			return Vector3(-1, 0, 0)
		return Vector3.ZERO # If unblocked, return no direction
	elif position.x < target_position.x and position.z < target_position.z: # Left Quadrant
		if obstacles["x_pos"] and obstacles["z_pos"]: # This means there are two obstacles completely blocking view of the target
			return Vector3.ZERO
		elif obstacles["x_pos"]: # One obstacle, peek in the positive z direction
			return Vector3(0, 0, 1)
		elif obstacles["z_pos"]: # One obstacle, peek in the positive x direction
			return Vector3(1, 0, 0)
		return Vector3.ZERO # If unblocked, return no direction
	elif position.x < target_position.x and position.z > target_position.z: # Bottom Quadrant
		if obstacles["x_pos"] and obstacles["z_neg"]: # This means there are two obstacles completely blocking view of the target
			return Vector3.ZERO
		elif obstacles["x_pos"]: # One obstacle, peek in the negative z direction
			return Vector3(0, 0, -1)
		elif obstacles["z_neg"]: # One obstacle, peek in the positive x direction
			return Vector3(1, 0, 0)
		return Vector3.ZERO # If unblocked, return no direction
	return Vector3.ZERO
