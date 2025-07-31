extends Node2D



var DRAW_DISTANCE = 250

var last_draw_point = Vector2.ZERO
var next_segment = 0

var is_drawing = false


@onready var brush = $Brush
var segments = null

@export var segment_amount = 20

func _ready() -> void:
	for i in range(0,segment_amount):
		$segments.add_child($segments/LineSegment.duplicate())
	segments = $segments.get_children()

func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	brush.position = mouse_pos
	
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
				prints("distance",line_distance)
				# if the mouse moves to fast we have to draw the points with correct spacing
				var segments_to_draw = int(line_distance / DRAW_DISTANCE) + 1
				var cur_segment: StaticBody2D = null
				
				var last_lerped_draw_point = last_draw_point
				prints("segments to draw:", segments_to_draw)
				prints("from point", last_draw_point,"to", mouse_pos)

				for i in range(0,segments_to_draw):
					if next_segment > segments.size()-1:
						break
					cur_segment = segments[next_segment]
					# lerp between current mouse pos and last draw point
					#prints("segment", i+1,"of", segments_to_draw)
					

					var cur_lerped_draw_point = lerp(last_draw_point, mouse_pos, float(i) / float(segments_to_draw))
					prints("lerped point", cur_lerped_draw_point)
					cur_segment.visible = true
					cur_segment.global_position = cur_lerped_draw_point
					_rotate_segment(cur_segment, last_lerped_draw_point)
					
					
					last_lerped_draw_point = cur_lerped_draw_point
					prints("segment",next_segment)
					
					next_segment += 1
					
				last_draw_point = last_lerped_draw_point
				print("___")
			
	else:
		if is_drawing:
			is_drawing = false


func _rotate_segment(segment: Node2D, last_point):
	var rotation_angle = segment.global_position.angle_to_point(last_point)
	segment.rotation = rotation_angle
