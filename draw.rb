def draw_floor(floor_width, floor_depth, floor_thickness)
  pt1 = [0.0, 0.0, 0.0]
  pt2 = [floor_width, 0.0, 0.0]
  pt3 = [floor_width, floor_depth, 0.0]
  pt4 = [0.0, floor_depth, 0.0]
  floor = Sketchup.active_model.active_entities.add_group()
  floor.entities.add_face(pt1, pt2, pt3, pt4).pushpull floor_thickness
  return floor
end

def draw_wall(x1, y1, x2, y2, wall_height)
  # TODO: Create screw holes
  entities = Sketchup.active_model.active_entities.add_group().entities

  pt1 = [x1, y1, 0.0]
  pt2 = [x1, y2, 0.0]
  pt3 = [x2, y2, 0.0]
  pt4 = [x2, y1, 0.0]
  new_face = entities.add_face pt1, pt2, pt3, pt4
  new_face.pushpull -wall_height
end

def draw_walls(floor_width, floor_depth, wall_thickness, shooter_lane_width, shooter_lane_start_depth, shooter_lane_end_depth, wall_height)
  draw_wall(0, 0, wall_thickness, floor_depth - wall_thickness, wall_height)
  draw_wall(0, floor_depth - wall_thickness, floor_width, floor_depth, wall_height)
  draw_wall(floor_width - wall_thickness, 0, floor_width, floor_depth - wall_thickness, wall_height)
  draw_wall(floor_width - wall_thickness - shooter_lane_width - wall_thickness, shooter_lane_start_depth, floor_width - wall_thickness - shooter_lane_width, shooter_lane_end_depth, wall_height)
end

def frame(x = 0.0, y = 0.0, z = 0.0, xaxis = nil, yaxis = nil, zaxis = nil)
  zaxis = Geom::Vector3d.new(0, 0, 1) if zaxis == nil
  xaxis = Geom::Vector3d.new(1, 0, 0) if xaxis == nil
  yaxis = zaxis * xaxis if yaxis == nil
  Geom::Transformation.axes(Geom::Point3d.new(x, y, z), xaxis, yaxis, zaxis)
end

def rotate(degrees)
  Geom::Transformation.rotation(Geom::Point3d.new, Geom::Vector3d.new(0, 0, 1), degrees.degrees)
end

def join_arcs(group, arcs)
  edges = []
  (0 .. arcs.length - 2).each do |i|
    edges += arcs[i]
    edges += group.entities.add_edges arcs[i].last.end, arcs[i+1].first.start
  end
  edges += arcs.last
  edges += group.entities.add_edges arcs.last.last.end, arcs.first.first.start
  return edges
end

def hole_from_face(floor, hole, face, depth)
  face.pushpull depth
  puts hole
  @floor = hole.subtract floor
end

def hole_from_edges(floor, hole, edges, depth)
  hole_from_face floor, hole, hole.entities.add_face(edges), depth
end

def draw_ball_trough(floor, floor_width, floor_thickness)
  t = frame(floor_width - (2.0 + 11.0/16.0), 47.0/8.0) * rotate(29.2)
  
  hole = Sketchup.active_model.active_entities.add_group()

  normal = Geom::Vector3d.new(0,0,1)
  xaxis = t * Geom::Vector3d.new(1,0,0)

  right_arc = hole.entities.add_arc t * Geom::Point3d.new, xaxis, normal, 5.0/8.0, -90.0.degrees, 90.0.degrees
  top_arc = hole.entities.add_arc t * Geom::Point3d.new(-33.0/4.0, 7.0/16.0, 0.0), xaxis, normal, 3.0/16.0, 90.0.degrees, 180.0.degrees
  bottom_arc = hole.entities.add_arc t * Geom::Point3d.new(-33.0/4.0, -7.0/16.0, 0.0), xaxis, normal, 3.0/16.0, 180.0.degrees, 270.0.degrees

  hole_from_edges floor, hole, join_arcs(hole, [right_arc, top_arc, bottom_arc]), floor_thickness
end

Sketchup.active_model.active_entities.each { |it| Sketchup.active_model.active_entities.erase_entities it }

t0 = Time.now.getutc

floor_width = 20.25
floor_depth = 42.0
floor_thickness = 17.0/32.0
wall_thickness = 0.5
wall_height = 1.125
shooter_lane_width = 1.375
shooter_lane_start_depth = 7.5
shooter_lane_end_depth = 16.125

floor = draw_floor(floor_width, floor_depth, floor_thickness)
draw_walls(floor_width, floor_depth, wall_thickness, shooter_lane_width, shooter_lane_start_depth, shooter_lane_end_depth, wall_height)
draw_ball_trough(floor, floor_width, floor_thickness)

puts Time.now.getutc - t0

Sketchup.send_action("viewTop:")
Sketchup.send_action("viewZoomExtents:")
