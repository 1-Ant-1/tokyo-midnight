
extends CharacterBody3D

const MAX_SPEED = 25.0
const MAX_REVERSE_SPEED = 10.0
const ACCELERATION = 12.0
const BRAKE_FORCE = 25.0
const TURN_SPEED = 2.0

const BOOST_MULTIPLIER = 1.5
const BOOST_DRAIN = 35.0
const BOOST_RECHARGE = 15.0

var current_speed = 0.0
var boost_amount = 100.0

func _physics_process(delta):
    var throttle = Input.get_action_strength("accelerate")
    var reverse = Input.get_action_strength("reverse")
    var brake = Input.get_action_strength("brake")
    var steering = Input.get_axis("steer_right", "steer_left")

    var boosting = (
        throttle > 0
        and Input.is_action_pressed("boost")
        and boost_amount > 0
    )

    var speed_limit = MAX_SPEED
    var acceleration = ACCELERATION

    if boosting:
        speed_limit *= BOOST_MULTIPLIER
        acceleration *= BOOST_MULTIPLIER
        boost_amount = maxf(boost_amount - BOOST_DRAIN * delta, 0.0)
    else:
        boost_amount = minf(boost_amount + BOOST_RECHARGE * delta, 100.0)

    if brake > 0:
        current_speed = move_toward(current_speed, 0.0, BRAKE_FORCE * delta)
    elif throttle > 0:
        current_speed = move_toward(current_speed, speed_limit, acceleration * delta)
    elif reverse > 0:
        current_speed = move_toward(current_speed, -MAX_REVERSE_SPEED, acceleration * delta)
    else:
        current_speed = move_toward(current_speed, 0.0, 4.0 * delta)

    rotation.y += steering * TURN_SPEED * delta * (current_speed / MAX_SPEED)

    var forward = -transform.basis.z
    velocity.x = forward.x * current_speed
    velocity.z = forward.z * current_speed
    velocity.y = 0.0

    move_and_slide()
