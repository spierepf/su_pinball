load "su_pinball/playfield.rb"
load "su_pinball/bezier_spline.rb"

Sketchup.active_model.active_entities.each { |it| Sketchup.active_model.active_entities.erase_entities it }

t0 = Time.now.getutc

playfield = Playfield.new()

playfield.draw_floor
playfield.draw_walls
playfield.draw_ball_trough
playfield.draw_handhold_notches
playfield.draw_hangers
playfield.draw_shooter_lane
playfield.draw_apron_mounts

upper_playfield = UpperPlayfield.new(playfield)
upper_playfield.draw_floor

playfield.wire_guide(BezierSpline.new([
  Geom::Point3d.new(playfield.floor_width-playfield.wall_thickness()-playfield.shooter_lane_width() - 3.0/64.0, playfield.floor_depth-(25.5),       (1.0 + 1.0/16.0)/2.0),
  Geom::Point3d.new(playfield.floor_width-playfield.wall_thickness()-playfield.shooter_lane_width() - 3.0/64.0, playfield.floor_depth-(19+15/16.0), (1.0 + 1.0/16.0)/2.0)
]))
  
playfield.wire_guide(BezierSpline.new([
  Geom::Point3d.new(playfield.floor_width-playfield.wall_thickness()-playfield.shooter_lane_width() - 3.0/64.0, playfield.floor_depth-(16+7/8.0), (1.0 + 1.0/16.0)/2.0),
  Geom::Point3d.new(playfield.floor_width-playfield.wall_thickness()-playfield.shooter_lane_width() - 3.0/64.0, playfield.floor_depth-(7+5/8.0),  (1.0 + 1.0/16.0)/2.0)
]))

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
  playfield.flipper_mechanics      left_flipper_frame * rotate(270)
  playfield.flipper_bat            left_flipper_frame
  playfield.flipper_index_pin_hole left_flipper_frame
  playfield.flipper_biff_bar       left_flipper_frame
  playfield.inlane_guide           left_flipper_frame
  
  #inlane
  playfield.rollover_switch        left_flipper_frame * frame(-(3.0 + 9.0/64.0), 5.0 + 5.0/32.0)
  
  #outlane
  x0 = playfield.wall_thickness
  x1 = left_flipper_frame_x - (4.0 + 1.0/16.0)  
  playfield.rollover_switch        frame((x0 + x1) / 2, 6 + 45.0/64.0 + 5.0 + 5.0/32.0)
  
  playfield.flipper_slingshot      left_flipper_frame, :left
  
  playfield.post(frame(1.5, 42.0 - (23.0 + 7.0/16.0)), :left_flipper_constellation_a)
  playfield.post(frame(1.0 + 1.0/8.0, 42.0 - (25.75)), :left_flipper_constellation_b)
  playfield.rubber([:left_flipper_constellation_a, :left_flipper_constellation_b])
end


def right_flipper_constellation(playfield)
  right_flipper_frame = frame(12.0 + 31.0/64.0, 6 + 45.0/64.0)
  playfield.flipper_mechanics      right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1) * rotate(180 - 29.2)
  playfield.flipper_bat            right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1)
  playfield.flipper_index_pin_hole right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1)
  playfield.flipper_biff_bar       right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1)
  playfield.inlane_guide           right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1)
  
  #inlane
  playfield.rollover_switch        right_flipper_frame * frame((3.0 + 9.0/64.0), 5.0 + 5.0/32.0)
  
  #outlane
  x0 = playfield.floor_width - (playfield.wall_thickness + playfield.shooter_lane_width + playfield.wall_thickness)
  x1 = right_flipper_frame_x + (4.0 + 1.0/16.0)  
  playfield.rollover_switch        frame((x0 + x1) / 2, 6 + 45.0/64.0 + 5.0 + 5.0/32.0)
  
  playfield.flipper_slingshot      right_flipper_frame, :right
  
  playfield.post(frame(20.25 - (3.0 + 7.0/16.0), 42.0 - (23.0 + 5.0/16.0)), :right_flipper_constellation_a)
  playfield.post(frame(20.25 - (2.0 + 5.0/8.0), 42.0 - (24.0 + 13.0/16.0)), :right_flipper_constellation_b)
  playfield.rubber([:right_flipper_constellation_a, :right_flipper_constellation_b])
end

def upper_left(playfield, upper_playfield)
  y = (42.0 - 5.0 - 5.0/16.0)

  start = Geom::Point3d.new(2.25, y, 0.0)
  stop = Geom::Point3d.new(8.5, y, 0.0)
  count = 3
  post_symbol_prefix = :upper_left_rake
  
  d = stop - start
  d.x = d.x / (2.0 * count)
  d.y = d.y / (2.0 * count)
  d.z = d.z / (2.0 * count)
  
  p = Geom::Transformation.translation(start)
  (0..count-1).each do |i|
    playfield.lane_guide p, (post_symbol_prefix.to_s + "_lane_guide_" + i.to_s).to_sym

    x0 = 1.0/8.0
    x1 = -1.0/8.0
    y0 = 31.0/64.0 - (1.0 + 7.0/16.0)
    y1 = y0 + 1.0/2.0
    y2 = y1 + 3.0/4.0
    y3 = y2 + 1.0/2.0
    hole = Sketchup.active_model.active_entities.add_group
    upper_playfield.hole_from_points(hole, [p * Geom::Point3d.new(x0, y0), p * Geom::Point3d.new(x0, y1), p * Geom::Point3d.new(x1, y1), p * Geom::Point3d.new(x1, y0)])
    hole = Sketchup.active_model.active_entities.add_group
    upper_playfield.hole_from_points(hole, [p * Geom::Point3d.new(x0, y2), p * Geom::Point3d.new(x0, y3), p * Geom::Point3d.new(x1, y3), p * Geom::Point3d.new(x1, y2)])
    
    upper_playfield.component(p * frame(0.0, -(1.0 + 7.0/16.0)), 'upper_playfield_lane_guide')
    p = p * Geom::Transformation.translation(d)

    playfield.rollover_switch p
    
    c1 = p * Geom::Point3d.new(0, 0, upper_playfield.z_offset)
    hypotenuse = 1.0
    c2 = p * frame(0.0, hypotenuse) * Geom::Point3d.new(0, 0, upper_playfield.z_offset)
    r1 = (1.0 + 3.0/16.0)/2.0
    r2 = (1.0/4.0)/2.0
    adjacent = r1 - r2
    theta = Math.acos(adjacent / hypotenuse)
    hole = Sketchup.active_model.active_entities.add_group
    upper_playfield.hole_from_edges(hole, join_arcs(hole, [hole.entities.add_arc(c2, Y_AXIS, Z_AXIS, r2, -theta, theta, 48), hole.entities.add_arc(c1, Y_AXIS, Z_AXIS, r1, theta, 360.degrees-theta, 48)]))
    
    hole = Sketchup.active_model.active_entities.add_group
    upper_playfield.hole_from_edges(hole, hole.entities.add_circle(p * Geom::Point3d.new(0.0, -(1.0 + 35.0/32.0), upper_playfield.z_offset), Z_AXIS, 1.0 + 1.0/8.0, 96))
    
    p = p * Geom::Transformation.translation(d)
  end
  playfield.lane_guide p, (post_symbol_prefix.to_s + "_lane_guide_3").to_sym

  p = Geom::Transformation.translation(d).inverse * Geom::Transformation.translation(start)
  hole = Sketchup.active_model.active_entities.add_group
  upper_playfield.hole_from_edges(hole, hole.entities.add_circle(p * Geom::Point3d.new(0.0, -(1.0 + 35.0/32.0), upper_playfield.z_offset), Z_AXIS, 1.0 + 1.0/8.0, 96))
  
  playfield.post frame(1.5,             42.0 - (3.0 + 7.0/16.0)),  :upper_left_a
  playfield.post frame(2.0 + 1.0/16.0,  42.0 - (7.0 + 3.0/16.0)),  :upper_left_b
  playfield.post frame(9.0 + 5.0/16.0,  42.0 - (4.0 + 3.0/16.0)),  :upper_left_c
  playfield.post frame(8.0,             42.0 - (7.0 + 5.0/16.0)),  :upper_left_d

  playfield.rubber([:upper_left_rake_lane_guide_0_a, :upper_left_a])
  playfield.rubber([:upper_left_rake_lane_guide_0_b, :upper_left_b])
  playfield.rubber([:upper_left_rake_lane_guide_1_a])
  playfield.rubber([:upper_left_rake_lane_guide_1_b])
  playfield.rubber([:upper_left_rake_lane_guide_2_a])
  playfield.rubber([:upper_left_rake_lane_guide_2_b])
  playfield.rubber([:upper_left_rake_lane_guide_3_a, :upper_left_c])
  playfield.rubber([:upper_left_rake_lane_guide_3_b, :upper_left_d])

  upper_playfield.draw_wall(0.0, upper_playfield.y_offset, upper_playfield.wall_thickness, playfield.floor_depth)
  upper_playfield.draw_wall(upper_playfield.wall_thickness, playfield.floor_depth - upper_playfield.wall_thickness, upper_playfield.floor_width - upper_playfield.wall_thickness, playfield.floor_depth, 4.0 + 5.0/8.0)
  
  upper_playfield.post frame(1.0, playfield.floor_depth - 1.0), :upper_playfield_a
  upper_playfield.circular_hole frame(1.0, playfield.floor_depth - 1.0), 3.0/32.0
  upper_playfield.post frame(2.0, playfield.floor_depth - 3.5), :upper_playfield_b
  upper_playfield.circular_hole frame(2.0, playfield.floor_depth - 3.5), 3.0/32.0
  upper_playfield.rubber([:upper_playfield_a, :upper_playfield_b])
end

def vendor_area(playfield)
  # pop bumpers
  playfield.pop_bumper frame(2.0 + 1.0/2.0, 42.0 - 9.0)
  playfield.pop_bumper frame(7.0,           42.0 - 9.0)
  playfield.pop_bumper frame(4.0 + 3.0/8.0, 42.0 - 12.5)

  playfield.post frame(7.0 + 13.0/16.0, 42.0 - (10.0 + 5.0/8.0)),  :upper_left_e
  playfield.post frame(1.0 + 3.0/16.0,  42.0 - (10.0 + 9.0/16.0)), :upper_left_f
  playfield.post frame(15.0/16.0,       42.0 - (13.0 + 7.0/16.0)), :upper_left_g
  playfield.post frame(1.0 + 5.0/16.0,  42.0 - (14.25)),           :upper_left_h
  playfield.post_with_tee frame(4.0 + 3.0/8.0,   42.0 - (16.75)),           :upper_left_i

  playfield.rubber_with_switch(:upper_left_f, :upper_left_g)
  playfield.rubber_with_switch(:upper_left_h, :upper_left_i)
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
    Geom::Point3d.new(3.0 + 3.0/16.0,  42.0-(17.0 + 3.0/8.0),  (1.0 + 1.0/8.0)/2.0),
    Geom::Point3d.new(2.0 + 11.0/16.0, 42.0-(19.0 + 9.0/32.0), (1.0 + 1.0/8.0)/2.0),
    Geom::Point3d.new(3.0 + 1.0/8.0,   42.0-(21.0 + 3.0/16.0), (1.0 + 1.0/8.0)/2.0)
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
    Geom::Point3d.new(20.25-(3.0 + 11.0/16.0), 42.0-(15.0 + 11.0/16.0), (1.0 + 1.0/8.0)/2.0),
    Geom::Point3d.new(20.25-(3.0 + 4.0/16.0),  42.0-(17.0 + 5.0/8.0),   (1.0 + 1.0/8.0)/2.0),
    Geom::Point3d.new(20.25-(3.0 + 11.0/16.0), 42.0-(19.0 + 9.0/16.0),  (1.0 + 1.0/8.0)/2.0)
  ]))
  playfield.large_arrow_insert(frame(14.75, 17.5) * rotate(330.0))
end

def left_drop_target_bank(playfield)
  playfield.drop_target_bank frame(4.5, 42.0 - 20.0) * rotate(250.0)
  playfield.bumper_post frame(4.0 + 11.0/16.0, 42.0 - (17.0 + 11.0/16.0))
  playfield.bumper_post frame(3.0 +  5.0/16.0, 42.0 - (21.0 + 11.0/16.0))
end

def right_drop_target_bank(playfield)
  playfield.drop_target_bank frame(20.25 - 4.5, 42.0 - 17.5) * rotate(100.0)
  playfield.bumper_post frame(20.25 - (4.0 +   1.0/2.0),  42.0 - (15.0 +  5.0/16.0))
  playfield.bumper_post frame(20.25 - (3.0 + 15.0/16.0),  42.0 - (19.0 + 11.0/16.0))
end

def inline_drop_target_bank(playfield)
  t = frame(20.25 - (7.0 + 13.0/16.0), 42.0 - (12.0 + 15.0/16.0)) * rotate(-13.0) * frame(0, 0.5)
  playfield.inline_drop_target_bank_2 t
  playfield.fixed_target(t * frame(0, 5.0 + 8.0/16.0))
  playfield.large_arrow_insert(t * frame(0.0, -4.5))
  playfield.post frame(20.25 - (6.0 + 35.0/64.0),  42.0 - (13.0 + 5.0/8.0)), :inline_drop_target_bank
  playfield.rubber([:inline_drop_target_bank])
  playfield.wire_guide(BezierSpline.new([
    t * Geom::Point3d.new(-18.0/16.0, -1.0, (1.0 + 1.0/8.0)/2.0),
    t * Geom::Point3d.new(-18.0/16.0,  5.25, (1.0 + 1.0/8.0)/2.0)
  ]))
  
  playfield.wire_guide(BezierSpline.new([
    t * Geom::Point3d.new(18.0/16.0, -9.0/16.0, (1.0 + 1.0/8.0)/2.0),
    t * Geom::Point3d.new(18.0/16.0,  5.25, (1.0 + 1.0/8.0)/2.0)
  ]))
  
  playfield.post(t * frame(-(1.0 + 3.0/8.0), 6.5))
end

def spinner_ramp(playfield)
  ramp_start_x0 = 20.25 - (12.0 + 3.0/8.0)
  ramp_start_x1 = 20.25 -  (9.0 + 1.0/4.0)
  ramp_start_y = 42.0-(13.0 + 9.0/16.0)
  playfield.post_with_tee frame(ramp_start_x0, ramp_start_y), :spinner_ramp_left
  playfield.post_with_tee frame(ramp_start_x1, ramp_start_y), :spinner_ramp_right
  playfield.rubber_with_switch(:spinner_ramp_left, :upper_left_e)
  playfield.rubber([:spinner_ramp_right])
  
  playfield.circular_hole(frame(ramp_start_x0 + 0.5, ramp_start_y), 1.0/8.0, nil, "mechanical")
  playfield.mini_post_6_32_with_tee(frame(ramp_start_x0 + 0.5, ramp_start_y - 5.0/8.0))

  playfield.large_arrow_insert(frame((ramp_start_x0 + ramp_start_x1) / 2, 25.5))
    
  return if playfield.cnc
  
  wireformTrough = WireFormTrough.new()
  plasticTrough = PlasticTrough.new()
  
  ballPath = BezierSpline.new([
    Geom::Point3d.new((ramp_start_x0 + ramp_start_x1) / 2, ramp_start_y, (1.0 + 1.0/16.0)/2.0),
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
  
#  (0..ballPath.length).each do |t|
#    Sketchup.active_model.active_entities.add_cpoint ballPath.f(t)
#  end
  
  (3..5).each do |t|
    wireformTrough.rib(ballPath, t, -60.degrees)
  end
  
  wireformTrough.singleGuide(ballPath, 3, 5, -60.degrees)
  
  (6..ballPath.length).each do |t|
    wireformTrough.rib(ballPath, t)
  end
  
  wireformTrough.doubleGuide(ballPath, 3, ballPath.length, 0.degrees)
  wireformTrough.doubleGuide(ballPath, 3, ballPath.length, 60.degrees)
  
  plasticTrough.trough(ballPath, 2.0, 7.0/8.0, 0, 3)
end

def draw_wall(x1, y1, x2, y2, z0, height)
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

def upper_playfield_ramp(playfield, upper_playfield)
  ramp_end_x = playfield.floor_width - (11.0 + 1.0/4.0)
  ramp_end_y = playfield.floor_depth - (3.0 + 1.0/16.0)

  pinballDiameter = 1.0 + 1.0/16.0
  ballPath = BezierSpline.new([
    Geom::Point3d.new(ramp_end_x, ramp_end_y, 0),
    Geom::Point3d.new(playfield.floor_width - (8.0 + 13.0/16.0), playfield.floor_depth - (3.0 + 2.0/8.0),    0),
    Geom::Point3d.new(playfield.floor_width - (7.0),             playfield.floor_depth - (4.0),              0),
    Geom::Point3d.new(playfield.floor_width - (5.0 + 7.0/16.0),  playfield.floor_depth - (5.0 + 5.0/16.0),   0),
    Geom::Point3d.new(playfield.floor_width - (4.0 + 5.0/16.0),  playfield.floor_depth - (6.0 + 7.0/8.0),    0),
    Geom::Point3d.new(playfield.floor_width - (3.0 + 5.0/8.0),   playfield.floor_depth - (8.0 + 7.0/8.0),    0),
    Geom::Point3d.new(playfield.floor_width - (3.0 + 3.0/4.0),   playfield.floor_depth - (10.0 + 13.0/16.0), 0),
    Geom::Point3d.new(playfield.floor_width - (4.0 + 1.0/2.0),   playfield.floor_depth - (12.0 + 11.0/16.0), 0),
    Geom::Point3d.new(playfield.floor_width - (5.0 + 1.0/2.0),   playfield.floor_depth - (14.0 + 1.0/2.0),   0),
  ])
  
  9.times { ballPath = upgrade_spline(ballPath) }
  
#  (0..ballPath.length).each do |t|
#    Sketchup.active_model.active_entities.add_cpoint ballPath.f(t)
#  end
  
  pathDiameter = 1.0 + 22.0/32.0

  playfield.large_arrow_insert(ballPath.frame(ballPath.length()-1) * frame(0, -1))
  playfield.large_arrow_insert(ballPath.frame(ballPath.length()-4) * frame(0, -1))
  playfield.large_arrow_insert(ballPath.frame(ballPath.length()-7) * frame(0, -1))

  troughPath = []
  (0..8).each do |i|
    troughPath.push ballPath.frame(i) * Geom::Point3d.new(0, 0, (1.0 + 7.0/8.0) * (1.0 / (1.0 + Math.exp(-(3.0 - i)/0.9))) + (pinballDiameter / 2.0))
  end

  ballPath.length.times { ballPath = upgrade_spline(ballPath) }
  
  sheetPath = []
  (16..ballPath.length).each do |i|
    sheetPath.push ballPath.frame(i) * Geom::Point3d.new((3.0/16.0 + pathDiameter/2.0), 0, 0)
  end
  playfield.sheet_guide(BezierSpline.new(sheetPath))
  
  wirePath = []
  (16..ballPath.length-1).each do |i|
    wirePath.push ballPath.frame(i) * Geom::Point3d.new(-(3.0/16.0 + pathDiameter/2.0), 0, (1.0 + 1.0/8.0)/2.0)
  end
  playfield.wire_guide(BezierSpline.new(wirePath))

  return if playfield.cnc()
  
  led_depth = 0.080
  led_width = 0.275
  
  13.times do |i|
    pt1 = Geom::Point3d.new(3.0/8.0 + i * (39.3701 / 60), playfield.floor_depth)
    pt2 = Geom::Point3d.new(3.0/8.0 + i * (39.3701 / 60) + led_width, playfield.floor_depth)
    pt3 = Geom::Point3d.new(3.0/8.0 + i * (39.3701 / 60) + led_width, playfield.floor_depth - led_depth)
    pt4 = Geom::Point3d.new(3.0/8.0 + i * (39.3701 / 60), playfield.floor_depth - led_depth)
    upper_playfield.hole_from_points(Sketchup.active_model.active_entities.add_group, [pt1, pt2, pt3, pt4])
  end
    
  PlasticTrough.new().trough(BezierSpline.new(troughPath), pathDiameter)

  x1 = upper_playfield.floor_width - playfield.wall_thickness
  y1 = ramp_end_y + (2.0 + 1.0/16.0)/2
  x2 = upper_playfield.floor_width
  y2 = playfield.floor_depth
  upper_playfield.draw_wall(x1, y1, x2, y2, 0.75)

  y1 = playfield.floor_depth - upper_playfield.floor_depth
  y2 = ramp_end_y - (2.0 + 1.0/16.0)/2
  upper_playfield.draw_wall(x1, y1, x2, y2, 1.0)
  
  upper_playfield.circular_hole(frame(upper_playfield.floor_width - 0.25, ramp_end_y - 1.25), 3.0/32.0)
  upper_playfield.circular_hole(frame(upper_playfield.floor_width - 0.25, ramp_end_y + 1.25), 3.0/32.0)
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
    Geom::Point3d.new(20.25-(1.0 + 15.0/16.0), 42.0-(7.0 + 3.0/16.0),  (1.0 + 1.0/8.0)/2.0),
    Geom::Point3d.new(20.25-(2.0 + 13.0/16.0), 42.0-(4.0 + 2.0/16.0),  (1.0 + 1.0/8.0)/2.0),
    Geom::Point3d.new(20.25-(5.0 + 3.0/8.0),   42.0-(2.0 + 2.0/8.0),   (1.0 + 1.0/8.0)/2.0),
    Geom::Point3d.new(20.25-(8.0 + 15.0/16.0), 42.0-(2.0 + 5.0/16.0),  (1.0 + 1.0/8.0)/2.0),
    Geom::Point3d.new(20.25-(10.0 + 9.0/16.0), 42.0-(3.0 + 17.0/32.0), (1.0 + 1.0/8.0)/2.0),
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
  playfield.round_insert(frame(play_area_center_x, 5), 1.5)

  playfield.round_insert(frame(6.5, 16), 1.0)
  playfield.round_insert(frame(10.5, 14), 1.0)
  playfield.round_insert(frame(13, 15), 1.0)
  
  flower_x = play_area_center_x + 0.75
  flower_y = 14.0 + 3.0
  (0..5).each do |i|
    playfield.triangle_insert frame(flower_x, flower_y) * rotate(i * 60.0 + 30.0) * frame(1.25) * rotate(-30.0)
  end
  
  [3.0, 4.0, 5.0 + 3.0/8.0].each do |y_offset|
    playfield.large_oval_insert frame(flower_x, flower_y + y_offset)
  end
  
  insert_spray_x = 5.5
  insert_spray_y = 24.0
  insert_spray_start_angle = 5.0
  insert_spray_spread = 35.0
  insert_spray_radius = 2.25
  
  (0..2).each do |i|
    playfield.round_insert(frame(insert_spray_x, insert_spray_y) * rotate(insert_spray_start_angle + i * insert_spray_spread) * frame(insert_spray_radius), 1.0)
  end
end

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

#draw_ball
#playfield.component(frame(), 'plastics')

left_flipper_constellation(playfield)
left_kickout(playfield)
left_drop_target_bank(playfield)

right_flipper_constellation(playfield)
right_kickout(playfield)
right_drop_target_bank(playfield)

upper_left(playfield, upper_playfield)
vendor_area(playfield)

spinner_ramp(playfield)
inline_drop_target_bank(playfield)
upper_playfield_ramp(playfield, upper_playfield)
top_curve(playfield)
center_lenses(playfield)

wood = Sketchup.active_model.materials.add
wood.color = '#ffd98d'
playfield.set_floor_material(wood)

plastic = Sketchup.active_model.materials.add
plastic.color = 'white'
plastic.alpha = 0.5
upper_playfield.set_floor_material(plastic)

puts Time.now.getutc - t0
#Sketchup.send_action("viewTop:")
#Sketchup.send_action("viewZoomExtents:")

# GI lighting
