class_name WanderState
extends NestedFSMState

@export var actor: Node3D
@export var delay: float = 2
@export var wander_positions: Array[Vector2i]

# Nested state machine for more complicated states
var null_state: State
var move_state: MoveState
var idle_state: IdleState

# Maybe add a "TimerIdle" state that incorporates the timer, would simplify things a bit
var timer: Timer

var wander_positions_index = 0

func _ready():
	# Nested FSM set-up
	fsm = FiniteStateMachine.new()
	null_state = State.new()
	move_state = MoveState.new()
	idle_state = IdleState.new()
	fsm.state = null_state
	move_state.actor = actor
	move_state.state_finished.connect(done_moving)
	add_child(fsm)
	fsm.add_child(null_state)
	fsm.add_child(move_state)
	fsm.add_child(idle_state)
	# Timer set-up
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = delay
	
	set_process(false)

func _enter_state() -> void:
	done_waiting()
	set_process(true)

func _exit_state() -> void:
	fsm.change_state(null_state)
	set_process(false)

func _process(delta):
	if (fsm.state == idle_state && timer.is_stopped()):
		done_waiting()

func done_moving():
	timer.start()
	fsm.change_state(idle_state)

func done_waiting():
	# Change target tile to next tile in the wander positions list
	actor.target_tile = wander_positions[wander_positions_index]
	if(wander_positions_index == wander_positions.size() - 1):
		wander_positions_index = 0
	else:
		wander_positions_index += 1
	fsm.change_state(move_state)
