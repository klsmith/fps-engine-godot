extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity = Vector2(100, 100);

@onready var camera_holder = $CameraHolder;
@onready var _viewport = get_viewport();

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _mouse_movement: Vector2;

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _unhandled_input(event):
	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
			toggle_mouse_mode();
	if event is InputEventMouseMotion:
		_mouse_movement += event.relative;
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_holder.camera.translate(Vector3(0, 0, -1));
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_holder.camera.translate(Vector3(0, -0, 1));

func toggle_mouse_mode():
	var new_mode;
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		new_mode = Input.MOUSE_MODE_VISIBLE;
	else:
		new_mode = Input.MOUSE_MODE_CAPTURED;
	Input.mouse_mode = new_mode;

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta;

	# Handle Jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY;

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector(
		"player_move_left",
		"player_move_right",
		"player_move_forward",
		"player_move_back"
	);
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	var speed = (SPEED * 1.5) if (Input.is_action_pressed("player_run")) else (SPEED);
	if direction:
		velocity.x = direction.x * speed;
		velocity.z = direction.z * speed;
	else:
		velocity.x = move_toward(velocity.x, 0, speed);
		velocity.z = move_toward(velocity.z, 0, speed);
	move_and_slide();

func _process(delta):
	process_camera_movement(delta);

func process_camera_movement(delta):
	var vsize = _viewport.get_visible_rect().size;
	if not camera_holder or not camera_holder.camera:
		return;
	camera_holder.rotate_x((_mouse_movement.y / vsize.y) * (-(mouse_sensitivity.y) * delta));
	camera_holder.rotation_degrees.x = clamp(camera_holder.rotation_degrees.x, -90, 90);
	rotate_y((_mouse_movement.x / vsize.x) * (-(mouse_sensitivity.x) * delta));
	_mouse_movement = Vector2(0,0);
