extends Node
class_name Builder2D


########################################################
# Methods                                              #
########################################################


# Add build up a collision shape node and add it to the target node.
static func add_collision_shape(target: Node2D, data: Dictionary)->void:
	var _CollisionShape = build_collision_shape(data)
	target.add_child(_CollisionShape)


# Build a collision shape form data.
static func build_collision_shape(data: Dictionary)->CollisionShape2D:
	assert(data.has("type"), "[Builder2D] No type provided for 'collision_shape'.")
	
	var _CollisionShape
	
	match data.type:
		"circle":
			_CollisionShape = build_collision_shape_circle(data)
		"rectangle":
			_CollisionShape = build_collision_shape_rectangle(data)
		_:
			assert(false, "[Builder2D] No valid type for collision_shape provided.")
	
	_CollisionShape.name = "CollisionShape"
	
	return _CollisionShape


# Build circle collision shape from data.
static func build_collision_shape_circle(data: Dictionary)->CollisionShape2D:
	var _CollisionShape = CollisionShape2D.new()
	var _Shape = CircleShape2D.new()
	_Shape.set_radius(data.radius)
	_CollisionShape.shape = _Shape
	_CollisionShape.set_position(Vector2(int(data.position.x) * 2, int(data.position.y) * 2))
	
	return _CollisionShape


# Build rectangle collision shape from data.
static func build_collision_shape_rectangle(data: Dictionary)->CollisionShape2D:
	var _CollisionShape = CollisionShape2D.new()

	var _Shape = RectangleShape2D.new()
	_Shape.set_extents(Vector2(int(data.extents.x), int(data.extents.y)))
	_CollisionShape.shape = _Shape
	_CollisionShape.set_position(Vector2(int(data.position.x) * 2, int(data.position.y) * 2))
	
	return _CollisionShape


# Build environment from data.
static func build_environment(data: Dictionary)->Environment:
	var _Environment = Environment.new()
	if data.has("mode"):
		match data.mode:
			"canvas":
				_Environment.background_mode = Environment.BG_CANVAS
				_Environment.background_canvas_max_layer = data.layers
	if data.has("glow"):
		_Environment.glow_enabled = true
		if data.glow.has("intensity"):
			_Environment.glow_intensity = data.glow.intensity
		if data.glow.has("strength"):
			_Environment.glow_strength = data.glow.strength
		if data.glow.has("levels"):
			for level in data.glow.levels:
				_Environment.set("glow_levels/" + str(level), true)
		if data.glow.has("blend_mode"):
			match data.glow.blend_mode:
				"additive":
					_Environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
				"softlight":
					_Environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
		if data.glow.has("hdr_threshold"):
			_Environment.glow_hdr_threshold = data.glow.hdr_threshold
			
	return _Environment


# Build up a sprite from data and add it as a child of target.
static func add_sprite(_Target : Node2D, data : Dictionary)->void:
	var _Sprite = build_sprite(data)
	_Target.add_child(_Sprite)


# Build sprite from data.
static func build_sprite(data: Dictionary)->Sprite:
	var _Sprite = Sprite.new()
	_Sprite.name = "Sprite"
	var _Image = Helper.decode_base64(data.data)
	var _Texture = ImageTexture.new()
	_Texture.create_from_image(_Image, 0)
	_Sprite.set_texture(_Texture)
	_Sprite.hframes = data.hframes
	_Sprite.vframes = data.vframes
	_Sprite.frame = data.frame
	return _Sprite


# Build single dialog from array of events.
static func build_dialog(name: String, data: Array)->Dialogic:
	var _Dialog = Dialogic.start(name)
	
	_Dialog.dialog_node.dialog_script = parse_dialog_data(data)
	
	return _Dialog


# Parse given dialog data to match dialogic dialog script.
# https://github.com/coppolaemilio/dialogic
# https://github.com/coppolaemilio/dialogic/blob/main/addons/dialogic/Documentation/Content/FAQ/create-timeline-using-gdscript.md
static func parse_dialog_data(data: Array)->Array:
	# Create container that we will return.
	var dialogic_timeline = {"events": []}
	
	# Parse the array of data to a dictionary with ids.
	var pool_of_events = {}
	for event in data:
		pool_of_events[event.id] = event
	
	# Use the pool_of_events to fill dialogic_timeline
	var start_event_id = pool_of_events.keys().front()
	add_to_dialogic_timeline(start_event_id, pool_of_events, dialogic_timeline)
	
	return dialogic_timeline

# Parse event and add it to the dialogic timeline.
static func add_to_dialogic_timeline(event_id: int, pool: Dictionary, timeline: Dictionary)->void:
	# Get event from pool of events.
	var event = pool[event_id]
	
	# For now we only handle 
	match event.type:
		"question":
			add_question_to_dialogic_timeline(event_id, pool, timeline)
		"choice":
			add_choice_to_dialogic_timeline(event_id, pool, timeline)
		"answer":
			add_text_to_dialogic_timeline(event_id, pool, timeline)
		_:
			pass

# Parse question event and add it to the timeline.
static func add_question_to_dialogic_timeline(event_id: int, pool: Dictionary, timeline: Dictionary)->void:
	# Get event from pool of events.
	var event = pool[event_id]
	
	# Create event data.
	var event_data = {
		"question": event.value,
		"event_id": "dialogic_010",
		"options": [],
		"character": "",
		"portrait": "",
	}
	
	# Add question.
	timeline["events"].append(event_data)
	
	# Add choices.
	if event.has("choices"):
		for choice in event.choices:
			add_to_dialogic_timeline(choice, pool, timeline)


# Parse choice event and add it to the timeline.
static func add_choice_to_dialogic_timeline(event_id: int, pool: Dictionary, timeline: Dictionary)->void:
	# Get event from pool of events.
	var event = pool[event_id]
	
	# Add choice.
	timeline["events"].append({
		"choice": event.value,
		"event_id": "dialogic_011",
		"condition": "",
		"definition": "",
		"value": ""
	})
	
	# Add next event.
	if event.has("next"):
		add_to_dialogic_timeline(event.next, pool, timeline)
	
	# Add action.
	if event.has("action"):
		add_action_to_dialogic_timeline(event.action, timeline)


# Parse choice event and add it to the timeline.
static func add_text_to_dialogic_timeline(event_id: int, pool: Dictionary, timeline: Dictionary)->void:
	# Get event from pool of events.
	var event = pool[event_id]
	
	# Add choice.
	timeline["events"].append({
		"text": event.value,
		"event_id": "dialogic_001",
		"character": "",
		"portrait": ""
	})
	
	# Add next event.
	if event.has("next"):
		add_to_dialogic_timeline(event.next, pool, timeline)
	
	# Add action.
	if event.has("action"):
		add_action_to_dialogic_timeline(event.action, timeline)

# Parse an given event for the dialogic timeline.
static func add_action_to_dialogic_timeline(action: String, timeline: Dictionary)->void:
	# Add the specific action.
	match action:
		"close":
			timeline["events"].append({
				"event_id": "dialogic_022",
				"transition_duration": 1
			})
			timeline["events"].append({
				"event_id": "dialogic_013"
			})
		# Catch all other actions.
		_:
			timeline["events"].append({
				"emit_signal": str(action),
				"event_id": "dialogic_040"
			})
