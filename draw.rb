load "su_pinball/playfield.rb"

Sketchup.active_model.active_entities.each { |it| Sketchup.active_model.active_entities.erase_entities it }

t0 = Time.now.getutc

playfield = Playfield.new()

playfield.draw_floor
playfield.draw_walls
playfield.draw_ball_trough

# left flipper constellation
left_flipper_frame = frame(5.0 + 57.0/64.0, 6 + 45.0/64.0) # left_flipper_frame = frame(5.0 + 41.0/64.0, 6 + 45.0/64.0)
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

# rake
y = (42.0 - 5.0 - 5.0/16.0)
playfield.rake Geom::Point3d.new(2.25, y, 0.0), Geom::Point3d.new(8.5, y, 0.0), 3

# pop bumpers
playfield.pop_bumper frame(2.0 + 1.0/2.0, 42.0 - 9.0)
playfield.pop_bumper frame(7.0,           42.0 - 9.0)
playfield.pop_bumper frame(4.0 + 3.0/8.0, 42.0 - 12.5)

# left kickout
playfield.kickout frame(2.0 + 3.0/8.0, 42.0 - 17.25) * rotate(255.0)
# right kickout
playfield.kickout frame(20.25 - (2 + 7.0/8.0), 42.0 - 15.75) * rotate(285.0)

# left drop target bank
playfield.drop_target_bank frame(4.5, 42.0 - 20.0) * rotate(250.0)
# right drop target bank
playfield.drop_target_bank frame(20.25 - 4.5, 42.0 - 17.5) * rotate(100.0)

# inline drop target bank
playfield.inline_drop_target_bank frame(20.25 - (7.0 + 13.0/16.0), 42.0 - (12.0 + 15.0/16.0)) * rotate(-13.0)

# posts
playfield.post frame(1.5,             42.0 - (3.0 + 7.0/16.0))
playfield.post frame(2.0 + 1.0/16.0,  42.0 - (7.0 + 3.0/16.0))
playfield.post frame(9.0 + 5.0/16.0,  42.0 - (4.0 + 3.0/16.0))
playfield.post frame(8.0,             42.0 - (7.0))
playfield.post frame(7.0 + 13.0/16.0, 42.0 - (10.0 + 5.0/8.0))
playfield.rubber([playfield.post(frame(1.0 + 3.0/16.0, 42.0 - (10.0 + 9.0/16.0))), playfield.post(frame(15.0/16.0, 42.0 - (13.0 + 7.0/16.0)))])
playfield.rubber([playfield.post(frame(1.0 + 5.0/16.0,  42.0 - (14.25))), playfield.post(frame(4.0 + 3.0/8.0,   42.0 - (16.75)))])
playfield.rubber([playfield.post(frame(1.5, 42.0 - (23.0 + 7.0/16.0))), playfield.post(frame(1.0 + 1.0/8.0, 42.0 - (26.25)))])
playfield.post frame(20.25 - (6.0 + 5.0/8.0),  42.0 - (13.0 + 5.0/8.0))
playfield.rubber([playfield.post(frame(20.25 - (3.0 + 7.0/16.0), 42.0 - (23.0 + 5.0/16.0))), playfield.post(frame(20.25 - (2.0 + 5.0/8.0), 42.0 - (24.0 + 13.0/16.0)))])

puts Time.now.getutc - t0

Sketchup.send_action("viewTop:")
Sketchup.send_action("viewZoomExtents:")
