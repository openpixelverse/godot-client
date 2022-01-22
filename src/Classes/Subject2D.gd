extends KinematicBody2D
class_name Subject2D


########################################################
# Member Variables                                     #
########################################################

var _States : StateMachine2D

var stats : SubjectStats2D

var direction : Vector2

var velocity : Vector2

var _AnimationPlayer : AnimationPlayer
var _AnimationTree : AnimationTree
var _AnimationStatePlayback

########################################################
# Hooks                                                #
########################################################


# NOTE:
#  _init() needs to be implemented by the inheriting class!


########################################################
# Setup                                                #
########################################################


# Setup the subject.
func setup_subject(data: Dictionary)->void:
	setup_stats(data)
	setup_states(data)
	setup_scale_factor(data)
	setup_direction(data)
	setup_sprite(data)
	setup_collision_shape(data)
	setup_animation(data)
	setup_position(data)


# Setup subject stats.
func setup_stats(data: Dictionary)->void:
	if data.has("stats"):
		stats = SubjectStats2D.new(data.stats)


# Setup the available states of the subject.
func setup_states(data: Dictionary)->void:
	if data.has("states"):
		var start_state = "idle"
		if data.has("start_state"):
			start_state = data.start_state
		_States = StateMachine2D.new(self, data.states, start_state)
		_States.name = "States"
		add_child(_States)


# Setup scale factor.
func setup_scale_factor(data: Dictionary)->void:
	if data.has("scale_factor"):
		set_scale(data.scale_factor)


# Setup the direction the player is looking to.
func setup_direction(data: Dictionary)->void:
	if data.has("direction"):
		direction = data.direction


# Setup the collision shape of the subject.
func setup_collision_shape(data: Dictionary)->void:
	if data.has("collision_shape"):
		Builder2D.add_collision_shape(self, data.collision_shape)


# Setup sprite.
func setup_sprite(data: Dictionary):
	# Check if we have data for the sprite.
	if data.has("sprite"):
		# Add sprite for animation to the subject.
		Builder2D.add_sprite(self, data.sprite)


# Setup the positon of the subject.
func setup_position(data : Dictionary)->void:
	if data.has("position"):
		position = data.position


# Setup animation of this subject.
func setup_animation(data: Dictionary):
	# Setup the animation player.
	setup_animation_player(data)
	# Setup the animation tree.
	setup_animation_tree(data)

# Setup the animation player of this subject.
func setup_animation_player(data: Dictionary):
	# Check if we received data for the animations.
	if data.animations:
		# Create AnimationPlayer node instance.
		_AnimationPlayer = Builder2D.build_animation_player(data.animations)
		
		# Add AnimationPlayer as child of the subject to the tree.
		add_child(_AnimationPlayer)


# Setup the animation tree.
func setup_animation_tree(data: Dictionary):
	# Check if we actually got animation tree data.
	if data.has("animation_tree"):
		# Create animation tree
		_AnimationTree = Builder2D.build_animation_tree(data.animation_tree, _AnimationPlayer.get_path())
		
		# Setup the animation state playback instance
		_AnimationStatePlayback = _AnimationTree.get("parameters/playback")
		
		# Add the animation tree to the nodes tree as child of this node.
		add_child(_AnimationTree)
