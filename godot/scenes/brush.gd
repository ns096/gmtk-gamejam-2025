extends Node2D



var DRAW_DISTANCE = 16

var last_draw_point = Vector2.ZERO
var next_segment = 0

var is_drawing = false


@onready var brush = $Brush
var segments = null

@export var segment_amount = 40

func _ready() -> void:
	SignalHub.loop_closed.connect(_on_loop_closed)
	
	for i in range(0,segment_amount):
		var seg  = $segments/LineSegment.duplicate()
		seg.line_number = i
		$segments.add_child(seg)
		
	segments = $segments.get_children()

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	brush.global_position = mouse_pos
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var line_vector = mouse_pos - last_draw_point
	
		if not is_drawing:
			# start line and reset old line
			last_draw_point = mouse_pos
			next_segment = 0
			for segment in segments:
				segment.visible = false
			is_drawing = true
		elif is_drawing:
			var line_distance = line_vector.length()
			if line_distance >= DRAW_DISTANCE and not (next_segment > segments.size()-1):

				# if the mouse moves to fast we have to draw the points with correct spacing
				var segments_to_draw = int(line_distance / DRAW_DISTANCE)
				var cur_segment: StaticBody2D = null
				
				var last_lerped_draw_point = last_draw_point


				for i in range(1,segments_to_draw + 1):
					if next_segment > segments.size()-1:
						break
					cur_segment = segments[next_segment]
					# lerp between current mouse pos and last draw point
					#prints("segment", i+1,"of", segments_to_draw)
					

					var cur_lerped_draw_point = lerp(last_draw_point, mouse_pos, float(i) / float(segments_to_draw))

					_move_segment(cur_segment,cur_lerped_draw_point, last_lerped_draw_point)
					
					
					last_lerped_draw_point = cur_lerped_draw_point
					
					next_segment += 1
					
				last_draw_point = last_lerped_draw_point
			
	else:
		if is_drawing:
			is_drawing = false


func _move_segment(segment: Node2D,cur_point, last_point):
	segment.visible = true
	segment.global_position = cur_point
	var rotation_angle = segment.global_position.angle_to_point(last_point)
	segment.rotation = rotation_angle

func _on_loop_closed(line_number: int):
	_loop_stuff(line_number, next_segment)

func _loop_stuff(start_seg, end_seg):
	var polygon: PackedVector2Array = []

	for i in range(start_seg, end_seg):
		polygon.append(segments[i].global_position)
	$Polygon2D.polygon = polygon
	
