
extends Camera3D

const FOLLOW_SPEED = 5.0
const BASE_FOV = 75.0
const MAX_FOV = 105.0
const MAX_SPEED = 45.0

const CAMERA_OFFSET = Vector3(0, 5, 10)

var car: CharacterBody3D

func _ready():
    car = get_parent() as CharacterBody3D
    current = true
    fov = BASE_FOV

func _physics_process(delta):
    if car == null:
        return

    var steering = Input.get_axis("steer_right", "steer_left")
    var dynamic_offset = CAMERA_OFFSET + Vector3(-steering * 1.2, 0, 0)
    var target_position = car.global_position + car.global_transform.basis * dynamic_offset

    global_position = global_position.lerp(
        target_position,
        clampf(FOLLOW_SPEED * delta, 0.0, 1.0)
    )

    look_at(car.global_position, Vector3.UP)

    var speed_ratio = clampf(absf(car.current_speed) / MAX_SPEED, 0.0, 1.0)
    var target_fov = lerpf(BASE_FOV, MAX_FOV, speed_ratio)

    fov = lerpf(fov, target_fov, clampf(3.0 * delta, 0.0, 1.0))
