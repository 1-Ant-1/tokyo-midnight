
extends CharacterBody3D

# --------------------------------
# PERFORMANCE
# --------------------------------

const MAX_SPEED = 25.0
const MAX_REVERSE_SPEED = 10.0
const ACCELERATION = 14.0
const BRAKE_FORCE = 30.0

# --------------------------------
# STEERING
# --------------------------------

const TURN_SPEED = 2.2
const DRIFT_TURN_MULTIPLIER = 1.5

# --------------------------------
# DRIFT PHYSICS
# --------------------------------

const NORMAL_GRIP = 10.0
const DRIFT_GRIP = 0.55
const DRIFT_SIDE_FORCE = 8.5

# --------------------------------
# BOOST
# --------------------------------

const BOOST_MULTIPLIER = 1.8
const BOOST_ACCELERATION = 1.5
const BOOST_DRAIN = 30.0
const BOOST_RECHARGE = 18.0

# --------------------------------
# VARIABLES
# --------------------------------

var current_speed = 0.0
var boost_amount = 100.0
var is_drifting = false
var is_boosting = false


func _physics_process(delta):

    # INPUT
    var throttle = Input.get_action_strength("accelerate")
    var reverse = Input.get_action_strength("reverse")
    var brake = Input.get_action_strength("brake")

    var steering = Input.get_axis(
        "steer_right",
        "steer_left"
    )

    # BOOST
    is_boosting = (
        throttle > 0
        and Input.is_action_pressed("boost")
        and boost_amount > 0
    )

    var speed_limit = MAX_SPEED
    var acceleration = ACCELERATION

    if is_boosting:
        speed_limit *= BOOST_MULTIPLIER
        acceleration *= BOOST_ACCELERATION

        boost_amount = maxf(
            boost_amount - BOOST_DRAIN * delta,
            0.0
        )
    else:
        boost_amount = minf(
            boost_amount + BOOST_RECHARGE * delta,
            100.0
        )

    # DRIFT DETECTION
    is_drifting = (
        brake > 0
        and throttle > 0
        and absf(steering) > 0.2
        and current_speed > 5.0
    )

    # ACCELERATION AND BRAKING
    if is_drifting:

        current_speed = move_toward(
            current_speed,
            speed_limit * 0.85,
            acceleration * 0.65 * delta
        )

    elif brake > 0:

        current_speed = move_toward(
            current_speed,
            0.0,
            BRAKE_FORCE * delta
        )

    elif throttle > 0:

        current_speed = move_toward(
            current_speed,
            speed_limit,
            acceleration * delta
        )

    elif reverse > 0:

        current_speed = move_toward(
            current_speed,
            -MAX_REVERSE_SPEED,
            ACCELERATION * delta
        )

    else:

        current_speed = move_toward(
            current_speed,
            0.0,
            4.0 * delta
        )

    # STEERING
    var speed_ratio = clampf(
        absf(current_speed) / MAX_SPEED,
        0.0,
        1.0
    )

    var steering_multiplier = 1.0

    if is_drifting:
        steering_multiplier = DRIFT_TURN_MULTIPLIER

    rotation.y += (
        steering
        * TURN_SPEED
        * steering_multiplier
        * speed_ratio
        * delta
    )

    # SIDEWAYS MOMENTUM
    var forward = -global_transform.basis.z
    var right = global_transform.basis.x

    var sideways_speed = velocity.dot(right)

    if is_drifting:

        sideways_speed += (
            steering
            * DRIFT_SIDE_FORCE
            * speed_ratio
            * delta
        )

    var grip = NORMAL_GRIP

    if is_drifting:
        grip = DRIFT_GRIP

    sideways_speed = move_toward(
        sideways_speed,
        0.0,
        grip * delta * absf(current_speed)
    )

    # FINAL VELOCITY
    velocity = (
        forward * current_speed
        + right * sideways_speed
    )

    velocity.y = 0.0

    move_and_slide()
