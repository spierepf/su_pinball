load "su_pinball/playfield.rb"

Sketchup.active_model.active_entities.each { |it| Sketchup.active_model.active_entities.erase_entities it }

t0 = Time.now.getutc

playfield = Playfield.new()

playfield.draw_floor
playfield.draw_walls
playfield.draw_ball_trough

# left_flipper_frame = frame(5.0 + 41.0/64.0, 6 + 45.0/64.0)
left_flipper_frame = frame(5.0 + 57.0/64.0, 6 + 45.0/64.0)
playfield.flipper_mechanics left_flipper_frame
playfield.flipper_bat left_flipper_frame
playfield.inlane_guide left_flipper_frame
playfield.rollover_switch left_flipper_frame * frame(-(3.0 + 9.0/64.0), 5.0 + 5.0/32.0)
playfield.rollover_switch left_flipper_frame * frame(-(4.0 + 38.0/64.0), 5.0 + 5.0/32.0)
playfield.flipper_slingshot left_flipper_frame, Geom::Transformation.new()

right_flipper_frame = frame(12.0 + 31.0/64.0, 6 + 45.0/64.0)
playfield.flipper_mechanics right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1) * rotate(90)
playfield.flipper_bat right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1)
playfield.inlane_guide right_flipper_frame * Geom::Transformation.scaling(-1, 1, 1)
playfield.rollover_switch right_flipper_frame * frame((3.0 + 9.0/64.0), 5.0 + 5.0/32.0)
playfield.rollover_switch right_flipper_frame * frame((4.0 + 38.0/64.0), 5.0 + 5.0/32.0)
playfield.flipper_slingshot right_flipper_frame, Geom::Transformation.scaling(-1, 1, 1)

puts Time.now.getutc - t0

Sketchup.send_action("viewTop:")
Sketchup.send_action("viewZoomExtents:")
