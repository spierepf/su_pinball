load "su_pinball/playfield.rb"
load "su_pinball/bezier_spline.rb"

Sketchup.active_model.active_entities.each { |it| Sketchup.active_model.active_entities.erase_entities it }

t0 = Time.now.getutc

playfield = Playfield.new()

playfield.draw_floor
playfield.draw_walls
playfield.draw_ball_trough
playfield.draw_handhold_notches

def left_flipper_frame_x
  5.0 + 57.0/64.0 # left_flipper_frame_x = 5.0 + 41.0/64.0
end

def right_flipper_frame_x
  12.0 + 31.0/64.0
end

def play_area_center_x 
  (left_flipper_frame_x + right_flipper_frame_x) / 2.0
end

def left_flipper_constellation(playfield)
  left_flipper_frame = frame(left_flipper_frame_x, 6 + 45.0/64.0) 
  playfield.flipper_mechanics left_flipper_frame
  playfield.flipper_bat left_flipper_frame
  playfield.inlane_guide left_flipper_frame
  playfield.rollover_switch left_flipper_frame * frame(-(3.0 + 9.0/64.0), 5.0 + 5.0/32.0)
  playfield.rollover_switch left_flipper_frame * frame(-(4.0 + 38.0/64.0), 5.0 + 5.0/32.0)
  playfield.flipper_slingshot left_flipper_frame, :left
  playfield.rubber([playfield.post(frame(1.5, 42.0 - (23.0 + 7.0/16.0))), playfield.post(frame(1.0 + 1.0/8.0, 42.0 - (26.25)))])
end


def right_flipper_constellation(playfield)
  right_flipper_frame = frame(12.0 + 31.0/64.0, 6 + 45.0/64.0)
  playfield.flipper_mechanics right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1) * rotate(90)
  playfield.flipper_bat right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1)
  playfield.inlane_guide right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1)
  playfield.rollover_switch right_flipper_frame * frame((3.0 + 9.0/64.0), 5.0 + 5.0/32.0)
  playfield.rollover_switch right_flipper_frame * frame((4.0 + 38.0/64.0), 5.0 + 5.0/32.0)
  playfield.flipper_slingshot right_flipper_frame, :right
  playfield.rubber([playfield.post(frame(20.25 - (3.0 + 7.0/16.0), 42.0 - (23.0 + 5.0/16.0))), playfield.post(frame(20.25 - (2.0 + 5.0/8.0), 42.0 - (24.0 + 13.0/16.0)))])
end

def drain_insert(playfield)
  playfield.round_insert(frame(play_area_center_x, 5), 1.5)
end

def upper_left(playfield)
  y = (42.0 - 5.0 - 5.0/16.0)
  playfield.rake Geom::Point3d.new(2.25, y, 0.0), Geom::Point3d.new(8.5, y, 0.0), 3
  
  # pop bumpers
  playfield.pop_bumper frame(2.0 + 1.0/2.0, 42.0 - 9.0)
  playfield.pop_bumper frame(7.0,           42.0 - 9.0)
  playfield.pop_bumper frame(4.0 + 3.0/8.0, 42.0 - 12.5)

  playfield.post frame(1.5,             42.0 - (3.0 + 7.0/16.0))
  playfield.post frame(2.0 + 1.0/16.0,  42.0 - (7.0 + 3.0/16.0))
  playfield.post frame(9.0 + 5.0/16.0,  42.0 - (4.0 + 3.0/16.0))
  playfield.post frame(8.0,             42.0 - (7.0))
  playfield.post frame(7.0 + 13.0/16.0, 42.0 - (10.0 + 5.0/8.0))
  playfield.rubber_with_switch(playfield.post(frame(1.0 + 3.0/16.0, 42.0 - (10.0 + 9.0/16.0))), playfield.post(frame(15.0/16.0, 42.0 - (13.0 + 7.0/16.0))))
  playfield.rubber_with_switch(playfield.post(frame(1.0 + 5.0/16.0,  42.0 - (14.25))), playfield.post(frame(4.0 + 3.0/8.0,   42.0 - (16.75))))
end

def left_kickout(playfield)
  playfield.kickout frame(2.0 + 3.0/8.0, 42.0 - 17.25) * rotate(255.0)
  playfield.sheet_guide(BezierSpline.new([
    Geom::Point3d.new(1.0 + 15.0/16.0, 42.0-(16.0 + 5.0/16.0), 0),
    Geom::Point3d.new(1.0 + 1.0/16.0,  42.0-(17.0 + 3.0/4.0),  0),
    Geom::Point3d.new(3.0/4.0,         42.0-(19.0 + 5.0/16.0), 0),
    Geom::Point3d.new(13.0/16.0,       42.0-(21.0 + 1.0/8.0),  0),
    Geom::Point3d.new(1.0+5.0/8.0,     42.0-(22.0 + 7.0/8.0),  0)
  ]))
  playfield.wire_guide(BezierSpline.new([
    Geom::Point3d.new(3.0 + 3.0/16.0,  42.0-(17.0 + 3.0/8.0), 0),
    Geom::Point3d.new(2.0 + 11.0/16.0, 42.0-(19.0 + 9.0/32.0), 0),
    Geom::Point3d.new(3.0 + 1.0/8.0,   42.0-(21.0 + 3.0/16.0), 0)
  ]))
  playfield.large_arrow_insert(frame(3.75, 17.5) * rotate(30.0))
end

def right_kickout(playfield)
  playfield.kickout frame(20.25 - (2 + 7.0/8.0), 42.0 - 15.75) * rotate(285.0)
  playfield.sheet_guide(BezierSpline.new([
    Geom::Point3d.new(20.25-(2.0 + 3.0/8.0),  42.0-(15.0 + 1.0/4.0),   0),
    Geom::Point3d.new(20.25-(2.0),            42.0-(17.0 + 1.0/8.0),   0),
    Geom::Point3d.new(20.25-(2.0 + 1.0/32.0), 42.0-(19.0),             0),
    Geom::Point3d.new(20.25-(2.0 + 9.0/16.0), 42.0-(20.0 + 7.0/8.0),   0),
    Geom::Point3d.new(20.25-(3.0 + 9.0/16.0), 42.0-(22.0 + 13.0/16.0), 0)
  ]))
  playfield.wire_guide(BezierSpline.new([
    Geom::Point3d.new(20.25-(3.0 + 11.0/16.0), 42.0-(15.0 + 11.0/16.0), 0),
    Geom::Point3d.new(20.25-(3.0 + 4.0/16.0),  42.0-(17.0 + 5.0/8.0),   0),
    Geom::Point3d.new(20.25-(3.0 + 11.0/16.0), 42.0-(19.0 + 9.0/16.0),  0)
  ]))
  playfield.large_arrow_insert(frame(14.75, 17.5) * rotate(330.0))
end

def left_drop_target_bank(playfield)
  playfield.drop_target_bank frame(4.5, 42.0 - 20.0) * rotate(250.0)
  playfield.component frame(4.0 + 11.0/16.0, 42.0 - (17.0 + 11.0/16.0)), 'Bumper Post 8-32 Thread bottom 6-32 at Top 024056'
  playfield.component frame(3.0 +  5.0/16.0, 42.0 - (21.0 + 11.0/16.0)), 'Bumper Post 8-32 Thread bottom 6-32 at Top 024056'
end

def right_drop_target_bank(playfield)
  playfield.drop_target_bank frame(20.25 - 4.5, 42.0 - 17.5) * rotate(100.0)
  playfield.component frame(20.25 - (4.0 +   1.0/2.0),  42.0 - (15.0 +  5.0/16.0)), 'Bumper Post 8-32 Thread bottom 6-32 at Top 024056'
  playfield.component frame(20.25 - (3.0 + 15.0/16.0),  42.0 - (19.0 + 11.0/16.0)), 'Bumper Post 8-32 Thread bottom 6-32 at Top 024056'
end

def inline_drop_target_bank(playfield)
  t = frame(20.25 - (7.0 + 13.0/16.0), 42.0 - (12.0 + 15.0/16.0)) * rotate(-13.0) * frame(0, 0.5)
  playfield.inline_drop_target_bank_2 t
  playfield.round_ended_hole(t * Geom::Transformation.translation(Geom::Point3d.new(0, 5.0 + 1.0/16.0, 0)) * rotate(90), 1.0 + 1.0/8.0, 0.5)
  playfield.large_arrow_insert(frame(11.5, 24.75) * rotate(-13.0))
  playfield.post frame(20.25 - (6.0 + 5.0/8.0),  42.0 - (13.0 + 5.0/8.0))
    
  rightside = 20 + 1/4.0
  topside = 42.0
  playfield.wire_guide(BezierSpline.new([
    Geom::Point3d.new(rightside-5.5,topside-(7.0+15/16.0),0.0),
    Geom::Point3d.new(rightside-(6+3/4.0),topside-(13+3/16.0),0.0)
  ]))
  playfield.wire_guide(BezierSpline.new([
    Geom::Point3d.new(rightside-(8+7/8.0),topside-(13+3/8.0),0.0),
    Geom::Point3d.new(rightside-(7+7/16.0),topside-(7.0+5/8.0),0.0)
  ]))
end

def spinner_ramp(playfield)
  ramp_start_x0 = 20.25 -  (9.0 + 1.0/4.0)
  ramp_start_x1 = 20.25 - (12.0 + 3.0/8.0)
  ramp_start_y = 42.0-(13.0 + 9.0/16.0)
  playfield.post frame(ramp_start_x0, ramp_start_y)
  playfield.post frame(ramp_start_x1, ramp_start_y)
  
  playfield.circular_hole(frame(ramp_start_x1 + 0.5, ramp_start_y), 1.0/8.0)
  wireformTrough = WireFormTrough.new()
  plasticTrough = PlasticTrough.new()
  
  ballPath = BezierSpline.new([
    Geom::Point3d.new((ramp_start_x0 + ramp_start_x1) / 2, ramp_start_y, 0.53125),
    Geom::Point3d.new( 9.7, 31.6, 0.81673828125),
    Geom::Point3d.new(11.4, 34.4, 1.7370703125),
    Geom::Point3d.new(14.5, 35.9, 2.0),
    Geom::Point3d.new(17.8, 35.1, 2.0),
    Geom::Point3d.new(19.3, 32.5, 2.0),
    Geom::Point3d.new(18.8, 29.9, 2.0),
    Geom::Point3d.new(16.8, 28.3, 2.0),
    Geom::Point3d.new(14.8, 26.8, 2.0),
    Geom::Point3d.new(13.9, 24.1, 2.0),
    Geom::Point3d.new(15.1, 21.1, 2.0),
    Geom::Point3d.new(17.3, 19.1, 2.0),
    Geom::Point3d.new(18.2, 17.0, 2.0),
    Geom::Point3d.new(17.4, 15.0, 2.0),
    Geom::Point3d.new(16.0, 13.6, 2.0)
  ])
  
  (0..ballPath.length).each do |t|
    Sketchup.active_model.active_entities.add_cpoint ballPath.f(t)
  end
  
  (3..5).each do |t|
    wireformTrough.rib(ballPath, t, -60.degrees)
  end
  
  wireformTrough.singleGuide(ballPath, 3, 5, -60.degrees)
  
  (6..ballPath.length).each do |t|
    wireformTrough.rib(ballPath, t)
  end
  
  wireformTrough.doubleGuide(ballPath, 3, ballPath.length, 0.degrees)
  wireformTrough.doubleGuide(ballPath, 3, ballPath.length, 60.degrees)
  
  plasticTrough.trough(ballPath, 0, 3)
  
  playfield.large_arrow_insert(frame((ramp_start_x0 + ramp_start_x1) / 2, 25.0))
end

def draw_wall(x1, y1, x2, y2, z0, height)
  # TODO: Create screw holes
  entities = Sketchup.active_model.active_entities.add_group().entities

  pt1 = [x1, y1, z0]
  pt2 = [x1, y2, z0]
  pt3 = [x2, y2, z0]
  pt4 = [x2, y1, z0]
  new_face = entities.add_face pt1, pt2, pt3, pt4
  new_face.pushpull -height
end

def upgrade_spline(spline)
  new_spline_length = spline.length + 1.0
  denominator = spline.length * new_spline_length
  
  tmp = []
  (0..new_spline_length).each do |i|
    tmp.push(spline.f(i * spline.length / new_spline_length))
  end
  
  BezierSpline.new(tmp)
end

def upper_playfield(playfield)
  upper_playfield = Sketchup.active_model.active_entities.add_group()
  width = 9.0
  depth = 6.0 + 3.0/8.0
  thickness = 1.0/4.0
  gap = 1.0/2.0
  
  pt1 = [0.0, playfield.floor_depth, playfield.wall_height + gap]
  pt2 = [width, playfield.floor_depth, playfield.wall_height + gap]
  pt3 = [width, playfield.floor_depth - depth, playfield.wall_height + gap]
  pt4 = [0.0, playfield.floor_depth - depth, playfield.wall_height + gap]
  upper_playfield.entities.add_face(pt1, pt2, pt3, pt4).pushpull -thickness

  13.times do |i|
    hole = Sketchup.active_model.active_entities.add_group()
    pt1 = [3.0/8.0 + i * (39.3701 / 60), playfield.floor_depth, playfield.wall_height + gap]
    pt2 = [3.0/8.0 + i * (39.3701 / 60) + 3.0/8.0, playfield.floor_depth, playfield.wall_height + gap]
    pt3 = [3.0/8.0 + i * (39.3701 / 60) + 3.0/8.0, playfield.floor_depth - 0.10, playfield.wall_height + gap]
    pt4 = [3.0/8.0 + i * (39.3701 / 60), playfield.floor_depth - 0.10, playfield.wall_height + gap]
    hole.entities.add_face(pt1, pt2, pt3, pt4).pushpull -thickness
    upper_playfield = hole.subtract(upper_playfield)
  end
  
    
  plastic = Sketchup.active_model.materials.add
  plastic.color = 'white'
  plastic.alpha = 0.5
  upper_playfield.material = plastic
  
  draw_wall(0, playfield.floor_depth - depth, playfield.wall_thickness, playfield.floor_depth - playfield.wall_thickness, playfield.wall_height + gap + thickness, playfield.wall_height)
  draw_wall(0, playfield.floor_depth - playfield.wall_thickness, width, playfield.floor_depth, playfield.wall_height + gap + thickness, playfield.wall_height)
  draw_wall(width - playfield.wall_thickness, playfield.floor_depth - depth, width, playfield.floor_depth - playfield.wall_thickness - 1.25, playfield.wall_height + gap + thickness, playfield.wall_height)

  ramp_start_x0 = 20.25-(5.0 + 3.0/8.0)
  ramp_start_x1 = 20.25-(6.0 + 1.0/8.0)
  ramp_start_y0 = 42.0-(4.0 + 1.0/16.0)
  ramp_start_y1 = 42.0-(5.0 +  13.0/16.0)

  ramp_end_x = width
  ramp_end_y0 = 41.0 + 7.0/8.0
  ramp_end_y1 = ramp_end_y0 - 2.0
  
  playfield.sheet_guide(BezierSpline.new([
    Geom::Point3d.new(20.25-(5.0 + 3.0/8.0),   42.0-(4.0 + 1.0/16.0),  0),
    Geom::Point3d.new(20.25-(3.0 + 1.0/4.0),   42.0-(6.0 + 5.0/8.0),   0),
    Geom::Point3d.new(20.25-(2.0 + 13.0/16.0), 42.0-(9.0 + 5.0/16.0),  0),
    Geom::Point3d.new(20.25-(3.0 + 3.0/8.0),   42.0-(12.0 + 1.0/16.0), 0),
    Geom::Point3d.new(20.25-(4.0 + 13.0/16.0), 42.0-(14.0 + 7.0/8.0),  0)
  ]))
  playfield.wire_guide(BezierSpline.new([
    Geom::Point3d.new(20.25-(6.0 + 1.0/8.0),   42.0-(5.0 +  13.0/16.0), 0),
    Geom::Point3d.new(20.25-(5.0),             42.0-(7.0 +  11.0/16.0), 0),
    Geom::Point3d.new(20.25-(4.0 + 11.0/16.0), 42.0-(9.0 +   9.0/16.0), 0),
    Geom::Point3d.new(20.25-(5.0 + 3.0/16.0),  42.0-(11.0 +  7.0/16.0), 0),
    Geom::Point3d.new(20.25-(6.0 + 3.0/16.0),  42.0-(13.0 + 11.0/32.0), 0)
  ]))
  playfield.large_arrow_insert(frame(15.0 + 1.0/8.0, 28.5) * rotate(-26.0))
  playfield.large_arrow_insert(frame(16.0 + 3.0/8.0, 31.5) * rotate(-8.0))
  playfield.large_arrow_insert(frame(16.0 + 2.0/8.0, 34.5) * rotate(30.0))

  r = 4.0
  delta = 1.0/16.0
  tmp = []
  (0.5).step(0.25, -delta) do |i|
    tmp.push(Geom::Point3d.new(ramp_end_x + r*Math.cos(i * 3.14159), ((ramp_end_y0 + ramp_end_y1) / 2) - r + r*Math.sin(i * 3.14159), 2.0))
  end

  5.times do |i|
    last = tmp.last()
    tmp.push(Geom::Point3d.new(last.x + delta * r * 3.14159 / Math.sqrt(2), last.y - delta * r * 3.14159 / Math.sqrt(2), 2.0))
  end
  
  tmp.each_index do |i|
    tmp[i].z = (1.0 + 7.0/8.0) * (1.0 / (1.0 + Math.exp(-(5.0 - i)))) + ((1.0 + 1.0/16.0) / 2.0);
  end
  
  ballPath = BezierSpline.new(tmp.reverse())
  
  (0..ballPath.length).each do |t|
    Sketchup.active_model.active_entities.add_cpoint ballPath.f(t)
    puts ballPath.f(t)
  end

  plasticTrough = PlasticTrough.new()
  plasticTrough.trough(ballPath)
end

def top_curve(playfield)
  # top right outer curve
  playfield.sheet_guide(BezierSpline.new([
    Geom::Point3d.new(20.25-(      7.0/16.0), 42.0-(6.0 + 10.0/16.0), 0),
    Geom::Point3d.new(20.25-(1.0 + 1.0/4.0),  42.0-(4.0 +  1.0/16.0), 0),
    Geom::Point3d.new(20.25-(3.0 + 1.0/16.0), 42.0-(1.0 + 15.0/16.0), 0),
    Geom::Point3d.new(20.25-(6.0 + 1.0/16.0), 42.0-(      12.0/16.0), 0),
    Geom::Point3d.new(20.25-(8.0 + 1.0/16.0), 42.0-(       9.0/16.0), 0),
  ]))
  
  # top right inner curve
  playfield.wire_guide(BezierSpline.new([
    Geom::Point3d.new(20.25-(1.0 + 15.0/16.0), 42.0-(7.0 + 3.0/16.0),  0),
    Geom::Point3d.new(20.25-(2.0 + 13.0/16.0), 42.0-(4.0 + 2.0/16.0), 0),
    Geom::Point3d.new(20.25-(5.0 + 3.0/8.0),   42.0-(2.0 + 2.0/8.0),   0),
    Geom::Point3d.new(20.25-(8.0 + 15.0/16.0), 42.0-(2.0 + 5.0/16.0),  0),
    Geom::Point3d.new(20.25-(10.0 + 9.0/16.0), 42.0-(3.0 + 17.0/32.0), 0),
  ]))
  
  # top curve
  playfield.sheet_guide(BezierSpline.new([
    Geom::Point3d.new(20.25-(8.0 + 1.0/16.0),  42.0-(       9.0/16.0), 0),
    Geom::Point3d.new(20.25-(14.0 + 1.0/16.0), 42.0-(       9.0/16.0), 0),
  ]))
  
  # top left curve
  playfield.sheet_guide(BezierSpline.new([
    Geom::Point3d.new(20.25-(14.0 + 1.0/16.0),  42.0-(       9.0/16.0), 0),
    Geom::Point3d.new(20.25-(15.0 + 10.0/16.0), 42.0-(      11.0/16.0), 0),
    Geom::Point3d.new(20.25-(17.0 + 1.0/16.0),  42.0-(      15.0/16.0), 0),
    Geom::Point3d.new(20.25-(18.0 + 10.0/16.0), 42.0-(1.0 +  9.0/16.0), 0),
    Geom::Point3d.new(20.25-(19.0 + 12.0/16.0), 42.0-(2.0 +  7.0/16.0), 0)
  ]))
  
  playfield.component(frame(1.0 + 1.0/16.0, 42.0 - (2.0 + 3.0/4.0)), "shooter_lane_stop_bumper")
end

def center_lenses(playfield)
  (0..5).each do |i|
    playfield.triangle_insert frame(play_area_center_x, 15.0) * rotate(i * 60.0 + 30.0) * frame(1.0) * rotate(-30.0)
  end
  
  lens_center_to_arc_center = (2.0 + 5.0/16.0 - 3.0/4.0) / 2
  (0..2).each do |i|
    playfield.large_oval_insert frame(play_area_center_x, 15.0) * rotate(i * 60.0 + 30.0) * frame(3.0 - lens_center_to_arc_center) * rotate(i * -60.0 + 60.0) * frame(lens_center_to_arc_center) 
  end
end

#left_flipper_constellation(playfield)
#right_flipper_constellation(playfield)
#playfield.round_insert(frame(play_area_center_x, 5), 1.5)
#upper_left(playfield)
#left_kickout(playfield)
#right_kickout(playfield)
#left_drop_target_bank(playfield)
#right_drop_target_bank(playfield)
#inline_drop_target_bank(playfield)
#spinner_ramp(playfield)
#upper_playfield(playfield)
#top_curve(playfield)
#center_lenses(playfield)

puts Time.now.getutc - t0

def draw_ball
  xaxis = Geom::Vector3d.new 1,0,0
  yaxis = Geom::Vector3d.new 1,0,0
  zaxis = Geom::Vector3d.new 0,0,1
  
  radius = (1.0 + 1.0/16.0)/2.0
  centerpoint = Geom::Point3d.new(12.0 + 1.0/4.0, 40.0 + 13.0/32.0, radius)
  
  # Create a circle perpendicular to the normal or Z axis
  circle1 = Sketchup.active_model.active_entities.add_circle centerpoint, zaxis, radius
  circle2 = Sketchup.active_model.active_entities.add_circle centerpoint, yaxis, radius * 2
  
  Sketchup.active_model.active_entities.add_face(circle1).followme(circle2)
  Sketchup.active_model.active_entities.erase_entities(circle2)
end

draw_ball

Sketchup.send_action("viewTop:")
Sketchup.send_action("viewZoomExtents:")

# shooter lane switch and centering guide trough thingie
# flipper back guards (3-1/8 long)
