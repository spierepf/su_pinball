def frame(x = 0.0, y = 0.0, z = 0.0, xaxis = nil, yaxis = nil, zaxis = nil)
  zaxis = Geom::Vector3d.new(0, 0, 1) if zaxis == nil
  xaxis = Geom::Vector3d.new(1, 0, 0) if xaxis == nil
  yaxis = zaxis * xaxis if yaxis == nil
  Geom::Transformation.axes(Geom::Point3d.new(x, y, z), xaxis, yaxis, zaxis)
end

def rotate(degrees)
  Geom::Transformation.rotation(Geom::Point3d.new, Geom::Vector3d.new(0, 0, 1), degrees.degrees)
end

class Playfield
  attr_reader :floor_width, :floor_depth, :floor_thickness, :wall_thickness, :wall_height, :shooter_lane_width, :shooter_lane_start_depth, :shooter_lane_end_depth 
  
  def initialize
    @floor = Sketchup.active_model.active_entities.add_group()
    @floor_width = 20.25
    @floor_depth = 42.0
    @floor_thickness = 17.0/32.0
    @wall_thickness = 0.5
    @wall_height = 1.125
    @shooter_lane_width = 1.375
    @shooter_lane_start_depth = 7.5
    @shooter_lane_end_depth = 16.125
    @items = []
  end

  def draw_floor
    pt1 = [0.0, 0.0, 0.0]
    pt2 = [@floor_width, 0.0, 0.0]
    pt3 = [@floor_width, @floor_depth, 0.0]
    pt4 = [0.0, @floor_depth, 0.0]
    @floor.entities.add_face(pt1, pt2, pt3, pt4).pushpull @floor_thickness
  end
  
  def draw_wall(x1, y1, x2, y2)
    # TODO: Create screw holes
    entities = Sketchup.active_model.active_entities.add_group().entities
  
    pt1 = [x1, y1, 0.0]
    pt2 = [x1, y2, 0.0]
    pt3 = [x2, y2, 0.0]
    pt4 = [x2, y1, 0.0]
    new_face = entities.add_face pt1, pt2, pt3, pt4
    new_face.pushpull -@wall_height
  end
  
  def draw_walls
    draw_wall(0, 0, @wall_thickness, @floor_depth - @wall_thickness)
    draw_wall(0, @floor_depth - @wall_thickness, @floor_width, @floor_depth)
    draw_wall(@floor_width - @wall_thickness, 0, @floor_width, @floor_depth - @wall_thickness)
    draw_wall(@floor_width - @wall_thickness - @shooter_lane_width - @wall_thickness, @shooter_lane_start_depth, @floor_width - @wall_thickness - @shooter_lane_width, @shooter_lane_end_depth)
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
  
  def hole_from_face(hole, face)
    face.pushpull @floor_thickness
    @floor = hole.subtract @floor
  end
  
  def hole_from_edges(hole, edges)
    hole_from_face hole, hole.entities.add_face(edges)
  end
  
  def draw_ball_trough()
    t = frame(@floor_width - (2.0 + 11.0/16.0), 47.0/8.0) * rotate(29.2)
    
    hole = Sketchup.active_model.active_entities.add_group()
  
    normal = Geom::Vector3d.new(0,0,1)
    xaxis = t * Geom::Vector3d.new(1,0,0)
  
    right_arc = hole.entities.add_arc t * Geom::Point3d.new, xaxis, normal, 5.0/8.0, -90.0.degrees, 90.0.degrees
    top_arc = hole.entities.add_arc t * Geom::Point3d.new(-33.0/4.0, 7.0/16.0, 0.0), xaxis, normal, 3.0/16.0, 90.0.degrees, 180.0.degrees
    bottom_arc = hole.entities.add_arc t * Geom::Point3d.new(-33.0/4.0, -7.0/16.0, 0.0), xaxis, normal, 3.0/16.0, 180.0.degrees, 270.0.degrees
  
    hole_from_edges hole, join_arcs(hole, [right_arc, top_arc, bottom_arc])
  end
  
  def template(t, name)
    filename = (File.dirname(__FILE__) + "/models/" + name + ".skp").gsub("/", "\\")
    component = Sketchup.active_model.definitions.load filename
    Sketchup.active_model.active_entities.add_instance(component, t * frame(0.0, 0.0, -@floor_thickness))
  end

  def component(t, name)
    filename = (File.dirname(__FILE__) + "/models/" + name + ".skp").gsub("/", "\\")
    component = Sketchup.active_model.definitions.load filename
    Sketchup.active_model.active_entities.add_instance(component, t)
  end
  
  def circular_hole(t, r)
    hole = Sketchup.active_model.active_entities.add_group()
    entities = hole.entities
  
    centerpoint = Geom::Point3d.new
    # Create a circle perpendicular to the normal or Z axis
    normal = Geom::Vector3d.new 0,0,1
    edges = entities.add_circle t * centerpoint, normal, r
  
    hole_from_edges hole, edges
  end
  
  def pilot_hole(t)
    # TODO: pilot holes should not be full depth
    circular_hole t, 1.0/32
  end
  
  def round_ended_hole(t, h, w)
    hole = Sketchup.active_model.active_entities.add_group()
  
    centerpoint = Geom::Point3d.new
    # Create a circle perpendicular to the normal or Z axis
    normal = Geom::Vector3d.new(0,0,1)
    xaxis = t * Geom::Vector3d.new(1,0,0)
  
    bottom_arc = hole.entities.add_arc t * frame(0.0, -(h - w) / 2.0) * centerpoint, xaxis, normal, w/2.0, 180.0.degrees, 360.0.degrees
    top_arc =    hole.entities.add_arc t * frame(0.0,  (h - w) / 2.0) * centerpoint, xaxis, normal, w/2.0, 0.0.degrees, 180.0.degrees
  
    hole_from_edges hole, join_arcs(hole, [bottom_arc, top_arc]) 
  end

  def flipper_mechanics t
    template(t, "Flipper\ Assy\ -\ Williams\ A-15205\ \(Left\)")
    [-17.0/32.0, -5.0/32.0, 89.0/32.0, 101.0/32.0].each do |x|
        [-17.0/8.0, 43.0/32.0].each do |y|
            pilot_hole(t * frame(x, y))
        end
    end
  end

  def flipper_bat t
    circular_hole(t, 0.25)
    component(t * rotate(-35.0), "flipper")
  end
    
  def inlane_guide t
    t2 = t * rotate(325)
    component(t2, "Inlane_DE-sega-stern")
    x = -4.25
    (0..2).each do
      pilot_hole(t2 * frame(x))
      x += 1 + 5.0/8.0
    end
  end
  
  def post t
    pilot_hole(t)
    component(t, "Star_Post_1-1'16_-03-8319-13")
  end
  
  def slingshot t
    round_ended_hole(t, 1.0, 0.5)
    circular_hole(t * frame(-1.0), 0.25)
    circular_hole(t * frame(1.0), 0.25)
  end
  
  def flipper_slingshot t, m
    post t * m * frame(-(0.0 + 25.0/32.0), 3.0 + 5.0/16.0)
    post t * m * frame(-(2.0 + 3.0/32.0),  4.0 + 7.0/32.0)
    post t * m * frame(-(2.0 + 3.0/16.0),  5.0 + 1.0/4.0)
    post t * m * frame(-(2.0 + 1.0/64.0),  6.0 + 29.0/32.0)
    slingshot t * m * frame(-(1.0 + 13.0/32.0), 5.0 + 1.0/8.0) * rotate(111.2) * m
  end
  
  def rollover_switch(t)
    template(t, "Rollover_Switch_and_Bracket_A-12688")
    round_ended_hole(t, 25.0/16.0, 3.0/16.0)
    pilot_hole(t * frame(31.0/64.0, -79.0/64.0, 0.0))
    pilot_hole(t * frame(31.0/64.0, -103.0/64.0, 0.0))
  end
end
