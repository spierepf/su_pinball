load "su_pinball/playfield.rb"
load "su_pinball/bezier_spline.rb"

Sketchup.active_model.active_entities.each { |it| Sketchup.active_model.active_entities.erase_entities it }

t0 = Time.now.getutc

playfield = Playfield.new()

playfield.draw_floor
playfield.draw_walls
playfield.draw_ball_trough

left_flipper_frame_x = 5.0 + 57.0/64.0 # left_flipper_frame_x = 5.0 + 41.0/64.0
right_flipper_frame_x = 12.0 + 31.0/64.0
play_area_center_x = (left_flipper_frame_x + right_flipper_frame_x) / 2.0

# left flipper constellation
left_flipper_frame = frame(left_flipper_frame_x, 6 + 45.0/64.0) 
playfield.flipper_mechanics left_flipper_frame
playfield.flipper_bat left_flipper_frame
playfield.inlane_guide left_flipper_frame
playfield.rollover_switch left_flipper_frame * frame(-(3.0 + 9.0/64.0), 5.0 + 5.0/32.0)
playfield.rollover_switch left_flipper_frame * frame(-(4.0 + 38.0/64.0), 5.0 + 5.0/32.0)
playfield.flipper_slingshot left_flipper_frame, :left

# right flipper constellation
right_flipper_frame = frame(12.0 + 31.0/64.0, 6 + 45.0/64.0)
playfield.flipper_mechanics right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1) * rotate(90)
playfield.flipper_bat right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1)
playfield.inlane_guide right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1)
playfield.rollover_switch right_flipper_frame * frame((3.0 + 9.0/64.0), 5.0 + 5.0/32.0)
playfield.rollover_switch right_flipper_frame * frame((4.0 + 38.0/64.0), 5.0 + 5.0/32.0)
playfield.flipper_slingshot right_flipper_frame, :right

playfield.round_insert(frame(play_area_center_x, 5), 1.5)

# rake
y = (42.0 - 5.0 - 5.0/16.0)
playfield.rake Geom::Point3d.new(2.25, y, 0.0), Geom::Point3d.new(8.5, y, 0.0), 3

# pop bumpers
playfield.pop_bumper frame(2.0 + 1.0/2.0, 42.0 - 9.0)
playfield.pop_bumper frame(7.0,           42.0 - 9.0)
playfield.pop_bumper frame(4.0 + 3.0/8.0, 42.0 - 12.5)

# left kickout
playfield.kickout frame(2.0 + 3.0/8.0, 42.0 - 17.25) * rotate(255.0)
# left kickout outer guide
playfield.sheet_guide(BezierSpline.new([
  Geom::Point3d.new(1.0 + 15.0/16.0, 42.0-(16.0 + 5.0/16.0), 0),
  Geom::Point3d.new(1.0 + 1.0/16.0,  42.0-(17.0 + 3.0/4.0),  0),
  Geom::Point3d.new(3.0/4.0,         42.0-(19.0 + 5.0/16.0), 0),
  Geom::Point3d.new(13.0/16.0,       42.0-(21.0 + 1.0/8.0),  0),
  Geom::Point3d.new(1.0+5.0/8.0,     42.0-(22.0 + 7.0/8.0),  0)
]))
# left kickout inner guide
playfield.wire_guide(BezierSpline.new([
  Geom::Point3d.new(3.0 + 3.0/16.0,  42.0-(17.0 + 3.0/8.0), 0),
  Geom::Point3d.new(2.0 + 11.0/16.0, 42.0-(19.0 + 9.0/32.0), 0),
  Geom::Point3d.new(3.0 + 1.0/8.0,   42.0-(21.0 + 3.0/16.0), 0)
]))

playfield.large_arrow_insert(frame(3.75, 17.5) * rotate(30.0))

# right kickout
playfield.kickout frame(20.25 - (2 + 7.0/8.0), 42.0 - 15.75) * rotate(285.0)
# right kickout outer guide
playfield.sheet_guide(BezierSpline.new([
  Geom::Point3d.new(20.25-(2.0 + 3.0/8.0),  42.0-(15.0 + 1.0/4.0),   0),
  Geom::Point3d.new(20.25-(2.0),            42.0-(17.0 + 1.0/8.0),   0),
  Geom::Point3d.new(20.25-(2.0 + 1.0/32.0), 42.0-(19.0),             0),
  Geom::Point3d.new(20.25-(2.0 + 9.0/16.0), 42.0-(20.0 + 7.0/8.0),   0),
  Geom::Point3d.new(20.25-(3.0 + 9.0/16.0), 42.0-(22.0 + 13.0/16.0), 0)
]))
# right kickout inner guide
playfield.wire_guide(BezierSpline.new([
  Geom::Point3d.new(20.25-(3.0 + 11.0/16.0), 42.0-(15.0 + 11.0/16.0), 0),
  Geom::Point3d.new(20.25-(3.0 + 4.0/16.0),  42.0-(17.0 + 5.0/8.0),   0),
  Geom::Point3d.new(20.25-(3.0 + 11.0/16.0), 42.0-(19.0 + 9.0/16.0),  0)
]))
playfield.large_arrow_insert(frame(14.75, 17.5) * rotate(330.0))

# left drop target bank
playfield.drop_target_bank frame(4.5, 42.0 - 20.0) * rotate(250.0)
playfield.component frame(4.0 + 11.0/16.0, 42.0 - (17.0 + 11.0/16.0)), 'Bumper Post 8-32 Thread bottom 6-32 at Top 024056'
playfield.component frame(3.0 +  5.0/16.0, 42.0 - (21.0 + 11.0/16.0)), 'Bumper Post 8-32 Thread bottom 6-32 at Top 024056'

# right drop target bank
playfield.drop_target_bank frame(20.25 - 4.5, 42.0 - 17.5) * rotate(100.0)
playfield.component frame(20.25 - (4.0 +   1.0/2.0),  42.0 - (15.0 +  5.0/16.0)), 'Bumper Post 8-32 Thread bottom 6-32 at Top 024056'
playfield.component frame(20.25 - (3.0 + 15.0/16.0),  42.0 - (19.0 + 11.0/16.0)), 'Bumper Post 8-32 Thread bottom 6-32 at Top 024056'

# inline drop target bank
t = frame(20.25 - (7.0 + 13.0/16.0), 42.0 - (12.0 + 15.0/16.0)) * rotate(-13.0)
playfield.inline_drop_target_bank t
playfield.round_ended_hole(t * Geom::Transformation.translation(Geom::Point3d.new(0, 5.0 + 1.0/16.0, 0)) * rotate(90), 1.0 + 1.0/8.0, 0.5)
playfield.large_arrow_insert(frame(11.5, 24.75) * rotate(-13.0))

# posts
playfield.post frame(1.5,             42.0 - (3.0 + 7.0/16.0))
playfield.post frame(2.0 + 1.0/16.0,  42.0 - (7.0 + 3.0/16.0))
playfield.post frame(9.0 + 5.0/16.0,  42.0 - (4.0 + 3.0/16.0))
playfield.post frame(8.0,             42.0 - (7.0))
playfield.post frame(7.0 + 13.0/16.0, 42.0 - (10.0 + 5.0/8.0))
playfield.rubber_with_switch(playfield.post(frame(1.0 + 3.0/16.0, 42.0 - (10.0 + 9.0/16.0))), playfield.post(frame(15.0/16.0, 42.0 - (13.0 + 7.0/16.0))))
playfield.rubber_with_switch(playfield.post(frame(1.0 + 5.0/16.0,  42.0 - (14.25))), playfield.post(frame(4.0 + 3.0/8.0,   42.0 - (16.75))))
playfield.rubber([playfield.post(frame(1.5, 42.0 - (23.0 + 7.0/16.0))), playfield.post(frame(1.0 + 1.0/8.0, 42.0 - (26.25)))])
playfield.post frame(20.25 - (6.0 + 5.0/8.0),  42.0 - (13.0 + 5.0/8.0))
playfield.rubber([playfield.post(frame(20.25 - (3.0 + 7.0/16.0), 42.0 - (23.0 + 5.0/16.0))), playfield.post(frame(20.25 - (2.0 + 5.0/8.0), 42.0 - (24.0 + 13.0/16.0)))])

playfield.post frame(20.25 -  (9.0 + 1.0/4.0), 42.0-(13.0 + 9.0/16.0))
playfield.post frame(20.25 - (12.0 + 3.0/8.0), 42.0-(13.0 + 9.0/16.0))

wireformTrough = WireFormTrough.new()

ballPath = BezierSpline.new([
  Geom::Point3d.new( 9.4, 28.4, 0.53125),
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

playfield.large_arrow_insert(frame(9.4, 25.0))

# upper playfield ramp outer guide
playfield.sheet_guide(BezierSpline.new([
  Geom::Point3d.new(20.25-(5.0 + 3.0/8.0),   42.0-(4.0 + 1.0/16.0),  0),
  Geom::Point3d.new(20.25-(3.0 + 1.0/4.0),   42.0-(6.0 + 5.0/8.0),   0),
  Geom::Point3d.new(20.25-(2.0 + 13.0/16.0), 42.0-(9.0 + 5.0/16.0),  0),
  Geom::Point3d.new(20.25-(3.0 + 3.0/8.0),   42.0-(12.0 + 1.0/16.0), 0),
  Geom::Point3d.new(20.25-(4.0 + 13.0/16.0), 42.0-(14.0 + 7.0/8.0),  0)
]))
# upper playfield ramp inner guide
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

(0..5).each do |i|
  playfield.triangle_insert frame(play_area_center_x, 15.0) * rotate(i * 60.0 + 30.0) * frame(1.0) * rotate(-30.0)
end

lens_center_to_arc_center = (2.0 + 5.0/16.0 - 3.0/4.0) / 2
(0..2).each do |i|
  playfield.large_oval_insert frame(play_area_center_x, 15.0) * rotate(i * 60.0 + 30.0) * frame(3.0 - lens_center_to_arc_center) * rotate(i * -60.0 + 60.0) * frame(lens_center_to_arc_center) 
end

puts Time.now.getutc - t0

Sketchup.send_action("viewTop:")
Sketchup.send_action("viewZoomExtents:")
