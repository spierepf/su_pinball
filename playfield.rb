def frame(x = 0.0, y = 0.0, z = 0.0, xaxis = nil, yaxis = nil, zaxis = nil)
  zaxis = Geom::Vector3d.new(0, 0, 1) if zaxis == nil
  xaxis = Geom::Vector3d.new(1, 0, 0) if xaxis == nil
  yaxis = zaxis * xaxis if yaxis == nil
  Geom::Transformation.axes(Geom::Point3d.new(x, y, z), xaxis, yaxis, zaxis)
end

def rotate(degrees)
  Geom::Transformation.rotation(Geom::Point3d.new, Geom::Vector3d.new(0, 0, 1), degrees.degrees)
end

def join_arcs(group, arcs, closed=true)
  edges = []
  (0 .. arcs.length - 2).each do |i|
    edges += arcs[i]
    edges += group.entities.add_edges arcs[i].last.end, arcs[i+1].first.start
  end
  edges += arcs.last
  edges += group.entities.add_edges arcs.last.last.end, arcs.first.first.start if closed
  return edges
end

def wireize (group, edges, wireradius)
  v = edges.first.vertices()
  centerpoint = Geom::Point3d.new(v[0])
  normal = Geom::Vector3d.new v[0].position.x-v[1].position.x,v[0].position.y-v[1].position.y,v[0].position.z-v[1].position.z
  group.entities.add_face(group.entities.add_circle(centerpoint, normal, wireradius, 12)).followme(edges)
  group.entities.erase_entities edges
end

def sheetmetalize (group, edges, height, thickness)
  v = edges.first.vertices()
  regpoint = Geom::Point3d.new(v[0])
  yaxis = Geom::Vector3d.new v[0].position.x-v[1].position.x,v[0].position.y-v[1].position.y,v[0].position.z-v[1].position.z
  zaxis = Geom::Vector3d.new(0,0,1)
  xaxis = yaxis * zaxis
  points = [
    regpoint + Geom::Vector3d.linear_combination(0.0, xaxis, 0.0, yaxis, 0.0, zaxis),
    regpoint + Geom::Vector3d.linear_combination(0.0, xaxis, 0.0, yaxis, height, zaxis),
    regpoint + Geom::Vector3d.linear_combination(thickness, xaxis, 0.0, yaxis, height, zaxis),
    regpoint + Geom::Vector3d.linear_combination(thickness, xaxis, 0.0, yaxis, 0.0, zaxis)
  ]
  face = group.entities.add_face points
  face.followme(edges)
end

def puts_point(p)
  puts "Geom::Point3d.new(" + p.x.to_f.to_s + ", " + p.y.to_f.to_s + ", " + p.z.to_f.to_s + "),"
end

def local_pushpull(face, height)
  height = -height if face.normal.z < 0
  face.pushpull height
end

class Post
  attr_reader :position

  def initialize(t)
    @position = t * Geom::Point3d.new()
  end
end

class WireFormTrough
  def initialize
    @troughDiameter = 1.0 + 1.0/8.0
    @wireDiameter = 1.0/8.0
  end
  
  def rib(spline, i, theta0=0.degrees, theta1=180.degrees)
    group = Sketchup.active_model.active_entities.add_group()
    frame = spline.frame(i)
    edges = group.entities.add_arc frame*Geom::Point3d.new, frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), (@troughDiameter + 3.0 * @wireDiameter) / 2.0, theta0, theta1
    wireize(group, edges, @wireDiameter/2.0)
  end
  
  def singleGuide(spline, i0, i1, theta)
    group = Sketchup.active_model.active_entities.add_group()

    railPoints = []
    (i0..i1).step(1.0/16.0) do |i|
      frame = spline.frame(i)
      point = frame * Geom::Transformation.rotation(Geom::Point3d.new, Geom::Vector3d.new(0, 1, 0), theta) * Geom::Point3d.new((@troughDiameter + @wireDiameter) / 2.0, 0, 0)
      railPoints.push(point) 
    end

    wireize(group, group.entities.add_curve(railPoints), @wireDiameter / 2.0)
  end
  
  def doubleGuide(spline, i0, i1, theta)
    group = Sketchup.active_model.active_entities.add_group()

    railPoints = [[],[]]
    (i0..i1).step(1.0/16.0) do |i|
      frame = spline.frame(i)
      railPoints[0].push(frame * Geom::Transformation.rotation(Geom::Point3d.new, Geom::Vector3d.new(0, 1, 0), theta) * Geom::Point3d.new((@troughDiameter + @wireDiameter) / 2.0, 0, 0)) 
      railPoints[1].unshift(frame * Geom::Transformation.rotation(Geom::Point3d.new, Geom::Vector3d.new(0, 1, 0), 180.degrees - theta) * Geom::Point3d.new((@troughDiameter + @wireDiameter) / 2.0, 0, 0)) 
    end
    
    frame = spline.frame(i1)
    tmp1 = group.entities.add_curve railPoints[0][0..railPoints[0].length-2]
    theta0 = 180.degrees + theta
    theta1 = 0.degrees - theta
    tmp2 = group.entities.add_arc frame * Geom::Point3d.new(0, -@troughDiameter / 2.0, -(@troughDiameter + @wireDiameter)/2.0 * Math.sin(theta)), frame * Geom::Vector3d.new(-1,0,0), frame * Geom::Vector3d.new(0,0,1), (@troughDiameter + @wireDiameter) / 2.0, theta0, theta1
    tmp3 = group.entities.add_curve railPoints[1][1..railPoints[1].length-1]
    edges = join_arcs(group, [tmp1, tmp2, tmp3], false)
    wireize(group, edges, @wireDiameter/2)
  end
end

class PlasticTrough
  def rib(group, spline, i, floor_width)
    fold_radius = 1.0/8.0
    plastic_thickness = 1.0/16.0
    descent = 13.0/32.0
    ascent = 17.0/32.0
    
    frame = spline.frame(i)
    
    arcs = []
    arcs.push group.entities.add_arc(frame*Geom::Point3d.new(-floor_width/2.0, 0, -descent), frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), fold_radius, 180.degrees, 90.degrees)
    arcs.push group.entities.add_arc(frame*Geom::Point3d.new(floor_width/2.0, 0, -descent), frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), fold_radius, 90.degrees, 0.degrees)

    arcs.push group.entities.add_arc(frame*Geom::Point3d.new(floor_width/2.0 + fold_radius + plastic_thickness + fold_radius, 0, ascent), frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), fold_radius + plastic_thickness, 180.degrees, 270.degrees)
    arcs.push group.entities.add_arc(frame*Geom::Point3d.new(floor_width/2.0 + fold_radius + plastic_thickness + fold_radius + 1.0/8.0, 0, ascent + plastic_thickness/2.0 + fold_radius), frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), plastic_thickness / 2.0, -90.degrees, 90.degrees)
    arcs.push group.entities.add_arc(frame*Geom::Point3d.new(floor_width/2.0 + fold_radius + plastic_thickness + fold_radius, 0, ascent), frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), fold_radius, 270.degrees, 180.degrees)

    arcs.push group.entities.add_arc(frame*Geom::Point3d.new(floor_width/2.0, 0, -descent), frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), fold_radius + plastic_thickness, 0.degrees, 90.degrees)
    arcs.push group.entities.add_arc(frame*Geom::Point3d.new(-floor_width/2.0, 0, -descent), frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), fold_radius + plastic_thickness, 90.degrees, 180.degrees)

    arcs.push group.entities.add_arc(frame*Geom::Point3d.new(-(floor_width/2.0 + fold_radius + plastic_thickness + fold_radius), 0, ascent), frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), fold_radius, 360.degrees, 270.degrees)
    arcs.push group.entities.add_arc(frame*Geom::Point3d.new(-(floor_width/2.0 + fold_radius + plastic_thickness + fold_radius + 1.0/8.0), 0, ascent + plastic_thickness/2.0 + fold_radius), frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), plastic_thickness / 2.0, 90.degrees, 270.degrees)
    arcs.push group.entities.add_arc(frame*Geom::Point3d.new(-(floor_width/2.0 + fold_radius + plastic_thickness + fold_radius), 0, ascent), frame*Geom::Vector3d.new(1,0,0), frame*Geom::Vector3d.new(0,1,0), fold_radius + plastic_thickness, 270.degrees, 360.degrees)
    edges = join_arcs(group, arcs)
  end

  def trough spline, width0, width1 = nil, t0 = 0, t1 = nil
    width1 = width0 if width1 == nil
    t1 = spline.length if t1 == nil
    
    m = (width1 - width0)/(t1 - t0)
    
    
    group = Sketchup.active_model.active_entities.add_group()
    
    transverse_edges = []
    (t0..t1).step(1.0/10.0) do |t|
      transverse_edges.push rib(group, spline, t, (m * t + width0))
    end
    
    group.entities.add_face(transverse_edges.first)
    group.entities.add_face(transverse_edges.last)
    transverse_edges.each_index do |i|
      if i != 0 
        transverse0 = transverse_edges[i-1]
        transverse1 = transverse_edges[i]
        transverse_edges[i].each_index do |j|
          p0 = transverse0[j].start.position
          p1 = transverse0[j].end.position
          p2 = transverse1[j].end.position
          p3 = transverse1[j].start.position

          begin
            group.entities.add_face(p0, p1, p2, p3)
          rescue
            group.entities.add_face(p0, p1, p2)
            group.entities.add_face(p0, p2, p3)
          end
        end
      end
    end
    
    plastic = Sketchup.active_model.materials.add
    plastic.color = 'white'
    plastic.alpha = 0.5
    group.material = plastic
    
    group.entities.grep(Sketchup::Edge).each do |e|
      next unless e.faces.length==2 && (e.faces[0].normal - e.faces[1].normal).length.abs < 0.5
      e.soft=true
      e.smooth=true
    end
  end
end

class Playfield
  attr_reader :floor_width, :floor_depth, :floor_thickness, :wall_thickness, :wall_height, :shooter_lane_width, :shooter_lane_start_depth, :shooter_lane_end_depth, :cnc 
  
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
    @posts = Hash.new
    
    @insert_thickness = 1.0/4.0
    @insert_depth = 7.0/32.0
    
    @x_offset = 0.0
    @y_offset = 0.0
    @z_offset = 0.0
    
    @cnc = false
  end

  def draw_floor
    pt1 = [@x_offset,                @y_offset,                @z_offset]
    pt2 = [@x_offset + @floor_width, @y_offset,                @z_offset]
    pt3 = [@x_offset + @floor_width, @y_offset + @floor_depth, @z_offset]
    pt4 = [@x_offset + 0.0,          @y_offset + @floor_depth, @z_offset]
    local_pushpull(@floor.entities.add_face(pt1, pt2, pt3, pt4), -@floor_thickness)
  end
  
  def set_floor_material(material)
    @floor.material = material
  end
  
  def draw_wall(x1, y1, x2, y2, pilot_spacing = 4.0)
    xc = (x2 + x1) / 2.0
    yc = (y2 + y1) / 2.0
    if (x2 - x1) > 1.0 then
      count = ((x2 - x1 - 1.0) / pilot_spacing).ceil
      offset = 0
      offset = pilot_spacing / 2.0 if count % 2 == 0
      (count / 2.0).ceil.times do |i|
        pilot_hole(frame(xc + offset, yc))
        pilot_hole(frame(xc - offset, yc)) if offset != 0
        offset += pilot_spacing
      end
    elsif (y2 - y1) > 1.0 then
      count = ((y2 - y1 - 1.0) / pilot_spacing).ceil
      offset = 0
      offset = pilot_spacing / 2.0 if count % 2 == 0
      (count / 2.0).ceil.times do |i|
        pilot_hole(frame(xc, yc + offset))
        pilot_hole(frame(xc, yc - offset)) if offset != 0
        offset += pilot_spacing
      end
    end
    
    return if cnc
    entities = Sketchup.active_model.active_entities.add_group().entities
  
    pt1 = [x1, y1, @z_offset]
    pt2 = [x1, y2, @z_offset]
    pt3 = [x2, y2, @z_offset]
    pt4 = [x2, y1, @z_offset]
    new_face = entities.add_face pt1, pt2, pt3, pt4
    local_pushpull(new_face, @wall_height)
  end
  
  def draw_walls
    draw_wall(0, 4.0 + 3.0/4.0, @wall_thickness, @floor_depth - @wall_thickness)
    draw_wall(0, @floor_depth - @wall_thickness, @floor_width, @floor_depth)
    draw_wall(@floor_width - @wall_thickness, 4.0 + 5.0/16.0, @floor_width, @floor_depth - @wall_thickness)
    draw_wall(@floor_width - @wall_thickness - @shooter_lane_width - @wall_thickness, @shooter_lane_start_depth, @floor_width - @wall_thickness - @shooter_lane_width, @shooter_lane_end_depth, 3.0)
  end
  
  def hole_from_face(hole, face, depth = nil, layer = nil)
    if layer != nil then
      Sketchup.active_model.layers.add layer
      hole.layer = layer if layer != nil
    end

    return if cnc
    
#    depth = @floor_thickness if depth == nil
#    local_pushpull face, -depth
#    @floor = hole.subtract @floor
  end
  
  def hole_from_edges(hole, edges, depth = nil, layer = nil)
    hole_from_face hole, hole.entities.add_face(edges), depth, layer
  end
  
  def hole_from_points(hole, points, depth = nil, layer = nil)
    points.each { |point| point.z = @z_offset }
    face = hole.entities.add_face(points)
    hole_from_face(hole, face, depth, layer)
  end

  def circular_hole(t, r, depth = nil, layer = nil)
    hole = Sketchup.active_model.active_entities.add_group()
    entities = hole.entities
    edgeCount = 24
    edgeCount = 96 if @cnc
  
    centerpoint = Geom::Point3d.new(0.0, 0.0, @z_offset)
    # Create a circle perpendicular to the normal or Z axis
    normal = Geom::Vector3d.new 0,0,1
    edges = entities.add_circle t * centerpoint, normal, r, edgeCount
  
    hole_from_edges hole, edges, depth, layer
  end
  
  def bottom_dimple(t)
  #  circular_hole t * frame(0, 0, -(@floor_thickness)), 5.0/128.0, 5.0/128.0
  end
  
  def pilot_hole(t, depth = nil)
    circular_hole t, (5.0/64.0)/2.0, depth, "pilot_hole"
  end
  
  def tee_pilot_hole_6_32 t
    circular_hole(t, (13.0/64.0)/2.0, nil, "tee_6_32")
  end
  
  def tee_pilot_hole_8_32 t
    circular_hole(t, (7.0/32.0)/2.0, nil, "tee_8_32")
  end
  
  def tee_pilot_hole_10_32 t
    circular_hole(t, (1.0/4.0)/2.0, nil, "tee_10_32")
  end
  
  def clearance_hole_8_32 t
    circular_hole t, 0.1640/2.0, nil, "clearance_8_32"
  end
  
  def round_ended_hole(t, h, w, depth = nil, layer=nil)
    hole = Sketchup.active_model.active_entities.add_group()
  
    centerpoint = Geom::Point3d.new
    # Create a circle perpendicular to the normal or Z axis
    normal = Geom::Vector3d.new(0,0,1)
    xaxis = t * Geom::Vector3d.new(1,0,0)
  
    bottom_arc = hole.entities.add_arc t * frame(0.0, -(h - w) / 2.0) * centerpoint, xaxis, normal, w/2.0, 180.0.degrees, 360.0.degrees
    top_arc =    hole.entities.add_arc t * frame(0.0,  (h - w) / 2.0) * centerpoint, xaxis, normal, w/2.0, 0.0.degrees, 180.0.degrees
  
    hole_from_edges hole, join_arcs(hole, [bottom_arc, top_arc]), depth, layer 
  end
  
  def lamp_hole(t)
    circular_hole(t, 0.25, nil, "mechanical")
  end
  
  def square_hole(t, x0, y0, x1, y1, depth = nil, layer = nil)
    hole = Sketchup.active_model.active_entities.add_group()
  
    pt1 = t * Geom::Point3d.new(x0, y0, 0.0)
    pt2 = t * Geom::Point3d.new(x1, y0, 0.0)
    pt3 = t * Geom::Point3d.new(x1, y1, 0.0)
    pt4 = t * Geom::Point3d.new(x0, y1, 0.0)
    hole_from_face hole, hole.entities.add_face(pt1, pt2, pt3, pt4), depth, layer
  end
  
  def draw_ball_trough()
    t = frame(@floor_width - (2.0 + 11.0/16.0), 47.0/8.0) * rotate(29.2)
    
    hole = Sketchup.active_model.active_entities.add_group()
  
    normal = Geom::Vector3d.new(0,0,1)
    xaxis = t * Geom::Vector3d.new(1,0,0)
  
    right_arc = hole.entities.add_arc t * Geom::Point3d.new, xaxis, normal, 41.0/64.0, -90.0.degrees, 90.0.degrees
    top_arc = hole.entities.add_arc t * Geom::Point3d.new(-33.0/4.0, 29.0/64.0, 0.0), xaxis, normal, 3.0/16.0, 90.0.degrees, 180.0.degrees
    bottom_arc = hole.entities.add_arc t * Geom::Point3d.new(-33.0/4.0, -29.0/64.0, 0.0), xaxis, normal, 3.0/16.0, 180.0.degrees, 270.0.degrees
  
    hole_from_edges hole, join_arcs(hole, [right_arc, top_arc, bottom_arc]), nil, "mechanical"

    round_ended_hole(t * frame(-33.0/4.0 - 1.0/16.0 - 1.0/8.0) * rotate(90.0), 7.0/8.0, 5.0/8.0, 1.0/4.0, "mechanical_shallow")
    
    circular_hole(t * frame(-33.0/4.0 - 3.0/16.0 - 1.0/8.0, -(1.0 + 5.0/16.0)), 1.0/4.0, 1.0/4.0, "mechanical_shallow")
    
    circular_hole(frame(16.0 + 3.0/4.0, 1.0 + 15.0/16.0), 5.0/8.0, nil, "mechanical")
    
    pilot_hole frame(6.0 + 5.0/8.0, 3.0 + 9.0/16.0)
    pilot_hole frame(8.0 + 3.0/4.0, 2.0 + 1.0/4.0)
    pilot_hole frame(@floor_width - (2.0 + 25.0/32.0), 4.0 + 19.0/32.0)
  end
  
  def draw_handhold_notches()
    square_hole(frame(), 0.0, 0.0, 1.0 + 1.0/8.0, 4.0 + 3.0/4.0)
    square_hole(frame(), 20.25 - (1.0 + 7.0/8.0), 0.0, 20.25, 4.0 + 1.0/4.0)
  end
  
  def draw_hangers()
    [1.0 + 1.0/8.0 + 13.0/16.0, 20.25 - (1.0 + 13.0/16.0) - 5.0/8.0].each do |x|
      [1.0 + 5.0/16.0, 2.0 + 7.0/8.0].each do |y|
        pilot_hole(frame(x, y))
      end
    end
  end
  
  def apron_mount(t)
    pilot_hole(t, 3.0/8.0)
    pilot_hole(t * frame(1.0 + 5.0/8.0), 3.0/8.0)
  end
  
  def draw_apron_mounts()
    apron_mount(frame(4.0 + 1.0/4.0, 5.0) * rotate(144.5))
    apron_mount(frame(4.0 + 1.0/4.0 + 9.0 + 3.0/4.0, 5.0) * rotate(29.5))
  end
  
  def draw_shooter_lane()
    shooter_lane_start_x = @floor_width - @wall_thickness - (@shooter_lane_width / 2.0)
    shooter_lane_start_y = 4.0 + 5.0/16.0
    
    rollover_switch(frame(shooter_lane_start_x, shooter_lane_start_y + (1.0 + 3.0/4.0 - 3.0/16.0) / 2.0 ), false)
    
    return if cnc
  
    launch_guide = Sketchup.active_model.active_entities.add_group()
    launch_angle = 1.0.degrees
    edges = launch_guide.entities.add_circle(Geom::Point3d.new(shooter_lane_start_x, shooter_lane_start_y - 1.0/8.0, 0.25), Geom::Vector3d.new(0, Math.cos(launch_angle), Math.sin(launch_angle)) , (1.0 + 1.0/16.0) / 2.0)
    face = launch_guide.entities.add_face(edges)
    face.pushpull(18.0)
    @floor = launch_guide.subtract @floor
  end
  
  def template(t, name)
    return if cnc
    filename = (File.dirname(__FILE__) + "/models/" + name + ".skp").gsub("/", "\\")
    component = Sketchup.active_model.definitions.load filename
    Sketchup.active_model.active_entities.add_instance(component, t * frame(0.0, 0.0, -@floor_thickness))
  end

  def component(t, name)
    return if cnc
    filename = (File.dirname(__FILE__) + "/models/" + name + ".skp").gsub("/", "\\")
    component = Sketchup.active_model.definitions.load filename
    Sketchup.active_model.active_entities.add_instance(component, t * frame(0,0,@z_offset))
  end
  
  def flipper_mechanics t
    template(t, "Flipper\ Assy\ -\ Williams\ A-15205\ \(Left\)")
    [-17.0/32.0, -5.0/32.0, 89.0/32.0, 101.0/32.0].each do |x|
        [-17.0/8.0, 43.0/32.0].each do |y|
            bottom_dimple(t * frame(x, y))
        end
    end
  end

  def flipper_bat t
    circular_hole(t, 0.25, nil, "mechanical")
    component(t * rotate(-35.0), "flipper")
  end
  
  def flipper_index_pin_hole t
    circular_hole(t * rotate(-35.0) * frame(2.0 + 3.0/32.0), 1.0/32.0, nil, "flipper_index_pin")
  end
  
  def flipper_biff_bar t
    wire_guide(BezierSpline.new([
      t * frame(0, -7.0/8.0, 3.0/64.0) * Geom::Point3d.new,
      t * frame(0, -7.0/8.0, 3.0/64.0) * rotate(-35.0) * frame(3.0 + 1.0/8.0) * Geom::Point3d.new
    ]))
    
  end
    
  def inlane_guide t
    t2 = t * rotate(325)
    component(t2, "Inlane_DE-sega-stern")
    x = -4.25
    (0..2).each do
      pilot_hole(t2 * frame(x), 3.0/8.0)
      x += 1 + 5.0/8.0
    end
    pilot_hole(t * frame(-(3.0 + 15.0/16.0), 7 + 17.0/64.0), 3.0/8.0)
  end
  
  def slingshot_solenoid_mount t
    template(t, "Solenoid Mount")
    [23.0/16.0, 15.0/16.0].each do |x|
        [-3.0/16.0, 3.0/16.0].each do |y|
            bottom_dimple(t * frame(x, y))
        end
    end
  end

  def slingshot_switch t
    circular_hole(t, 0.25, nil, "mechanical")
    template(t, "Slingshot Switch")
    bottom_dimple(t * frame(0, -19.0/32.0))
    bottom_dimple(t * frame(0, -35.0/32.0))
  end

  def slingshot t
    round_ended_hole(t, 1.0, 0.5, nil, "mechanical")
    template(t * frame(0, -3.0/8.0), "Kicker_Arm_Sllingshot_Assembly_B-12665")
    bottom_dimple(t * frame(31.0/64.0, -18.0/32.0))
    bottom_dimple(t * frame(31.0/64.0, -6.0/32.0))
    bottom_dimple(t * frame(-2.0/64.0, -22.0/32.0))
    bottom_dimple(t * frame(-22.0/64.0, -22.0/32.0))

    slingshot_solenoid_mount(t * frame(1.0/8.0, -(1.0 + 31.0/32.0)))
    slingshot_switch(t * frame(1.0))
    slingshot_switch(t * frame(-1.0))
  end
  
  def round_cornered_polygon(group, vertices, arc_radius)
    arcs = []
    vertices.each_with_index do |vertex, i|
      v0 = vertices[i - 1] - vertex
      theta0 = Math::atan2(v0.y, v0.x)
      v1 = vertices[(i + 1) % vertices.length] - vertex
      theta1 = Math::atan2(v1.y, v1.x)

      theta0 -= 90.degrees
      if vertices.length > 2 then
        theta1 += 90.degrees
        theta0 += 360.degrees if theta0 < 0 and vertices.length > 2
        theta1 -= 360.degrees if theta0 < 180.degrees and theta1 > 180.degrees and vertices.length > 2
      else
        theta1 = theta0 - 180.degrees
      end
      
      edgeCount = (((theta0-theta1)/(2*Math::PI)) * (@cnc ? 96 : 24)).floor
      
      arcs.push(group.entities.add_arc(vertex, Geom::Vector3d.new(1,0,0), Geom::Vector3d.new(0,0,1), arc_radius, theta0, theta1, edgeCount))
    end
    join_arcs(group, arcs)
  end
  
  def rubber(post_symbols)
    rubberRadius = 3.0/32.0
    postRadius = 27.0/128.0
    postHeight = 43.0/64.0
    
    return if cnc
    posts = []
    post_symbols.each do |s|
      posts.push @posts[s] if @posts[s] != nil
    end
    return if posts == []

    rubber = Sketchup.active_model.active_entities.add_group()
    if posts.length == 1 then
      centerpoint = posts[0].position + Geom::Vector3d.new(0,0,postHeight + @z_offset)
      perimeter = rubber.entities.add_circle(centerpoint, Geom::Vector3d.new(0,0,1), postRadius + rubberRadius)
    else
      arcs = []
      posts.each_with_index do |post, i|
        v0 = posts[i - 1].position - post.position
        theta0 = Math::atan2(v0.y, v0.x)
        v1 = posts[(i + 1) % posts.length].position - post.position
        theta1 = Math::atan2(v1.y, v1.x)
    
        theta0 += 270.degrees
        theta1 += 90.degrees
        theta0 += 360.degrees if theta0 < 0 and posts.length > 2
        theta1 += 360.degrees if theta1 < 0 and posts.length > 2
  
        centerpoint = post.position + Geom::Vector3d.new(0,0,postHeight + @z_offset)
        arcs.push(rubber.entities.add_arc(centerpoint, Geom::Vector3d.new(1,0,0), Geom::Vector3d.new(0,0,1), postRadius + rubberRadius, theta0, theta1))
      end
      perimeter = join_arcs(rubber, arcs)
    end
    circumference = 0.0
    perimeter.each { |edge| circumference = circumference + edge.length }
    innerDiameter = (((circumference) - (2 * rubberRadius * Math::PI)) / Math::PI) / 1.2
    puts "Ring inner diameter: #{innerDiameter}"
    
    wireize(rubber, perimeter, rubberRadius)
  end
  
  def rubber_with_switch(post_symbol1, post_symbol2)
    rubber([post_symbol1, post_symbol2])

    post1 = @posts[post_symbol1]
    post2 = @posts[post_symbol2]
    return if post1 == nil or post2 == nil
    
    width = (post1.position - post2.position).length
    center = Geom::Point3d.new((post1.position.x + post2.position.x) / 2.0, (post1.position.y + post2.position.y) / 2.0, (post1.position.z + post2.position.z) / 2.0)
    xaxis = (post1.position - post2.position).normalize!
    zaxis = Geom::Vector3d.new(0,0,1)
    yaxis = zaxis * xaxis
    frame = Geom::Transformation.axes(center, xaxis, yaxis, zaxis)
    
    slingshot_switch frame
    
    wire_guide(BezierSpline.new([
      frame * Geom::Point3d.new(7.0/16.0, 0,            (1.0 + 1.0/8.0)/2.0),
      frame * Geom::Point3d.new((width / 2.0 - 0.5), 0, (1.0 + 1.0/8.0)/2.0)
    ]))
    
    wire_guide(BezierSpline.new([
      frame * Geom::Point3d.new(-(7.0/16.0), 0,          (1.0 + 1.0/8.0)/2.0),
      frame * Geom::Point3d.new(-(width / 2.0 - 0.5), 0, (1.0 + 1.0/8.0)/2.0)
    ]))
  end
  
  def flipper_slingshot t, side
    if side == :left
      m = Geom::Transformation.new
    else
      m = Geom::Transformation.scaling(-1, 1, 1)
    end
    
    post_with_tee(t * m * frame(-(0.0 + 25.0/32.0), 3.0 + 5.0/16.0),  ("flipper_slingshot_"+side.to_s+"_a").to_sym)
    post(t * m * frame(-(2.0 + 3.0/32.0),  4.0 + 7.0/32.0),  ("flipper_slingshot_"+side.to_s+"_b").to_sym)
    post(t * m * frame(-(2.0 + 3.0/16.0),  5.0 + 1.0/4.0),   ("flipper_slingshot_"+side.to_s+"_c").to_sym)
    post_with_tee(t * m * frame(-(2.0 + 1.0/64.0),  6.0 + 29.0/32.0), ("flipper_slingshot_"+side.to_s+"_d").to_sym)
    
    rubber([:flipper_slingshot_left_a, :flipper_slingshot_left_b, :flipper_slingshot_left_c, :flipper_slingshot_left_d]) if side == :left
    rubber([:flipper_slingshot_right_d, :flipper_slingshot_right_c, :flipper_slingshot_right_b, :flipper_slingshot_right_a]) if side == :right
    
    theta = Math.atan2((3.0 + 5.0/16.0) - (6.0 + 29.0/32.0), (-(0.0 + 25.0/32.0)) - (-(2.0 + 1.0/64.0))).radians
    slingshot t * m * frame(-(1.0 + 13.0/32.0), 5.0 + 1.0/8.0) * rotate(180.0 + theta) * m
  end
  
  def rollover_switch(t, insert = true)
    template(t, "Switch Rollover - Sys7")
    round_ended_hole(t, 1.0 + 3.0/4.0, 3.0/16.0, nil, "rollover_switch")
    
    bottom_dimple(t * frame(23.0/32.0, 15.0/16.0))
    bottom_dimple(t * frame(23.0/32.0, 1.0 + 5.0/16.0))
    bottom_dimple(t * frame(-5.0/32.0, 1.0 + 5.0/16.0))
      
    template(t * frame((23.0/32.0 - 5.0/32.0)/2, 1.25), "Rollover Switch")
    bottom_dimple(t * frame((23.0/32.0 - 5.0/32.0)/2, 1.25) * frame(0, -(1.0 + 15.0/16.0)))
    bottom_dimple(t * frame((23.0/32.0 - 5.0/32.0)/2, 1.25) * frame(0, -(1.0 + 15.0/16.0 + 3.0/8.0)))

    round_insert(t * frame(0.0, 2.25), 3.0/4.0) if(insert)
  end
  
  def lane_guide(t, post_symbol_prefix)
    post t * frame(0, 0.625), (post_symbol_prefix.to_s + "_a").to_sym
    post_with_tee t * frame(0, -0.625), (post_symbol_prefix.to_s + "_b").to_sym
    component t, "Lane_Guide_03-8318-25"
    lamp_hole t
  end
  
  def pop_bumper(t)
    # Ring and rod holes
    circular_hole(t * frame(11.0/16.0, 0.0, 0.0), 3.0/16.0, nil, "mechanical")
    circular_hole(t * frame(-11.0/16.0, 0.0, 0.0), 3.0/16.0, nil, "mechanical")
    
    # Skirt shaft hole
    circular_hole(t, 21.0/64.0, nil, "mechanical")

    # Lamp lead holes
    t2 = t * rotate(-45.0)
#    circular_hole(t2 * frame(11.0/32.0, 0.0, 0.0), 3.0/16.0)
#    circular_hole(t2 * frame(-11.0/32.0, 0.0, 0.0), 3.0/16.0)
    round_ended_hole(t2 * rotate(90.0), 34.0/32.0, 6.0/16.0, nil, "mechanical")

    # Coil bracket (hammer screw) holes
#    circular_hole(t * frame(0.0, 17.0/16.0, 0.0), 3.0/64.0)
#    circular_hole(t * frame(1.0, 7.0/16.0, 0.0), 3.0/64.0)
#    circular_hole(t * frame(-1.0, 7.0/16.0, 0.0), 3.0/64.0)
    circular_hole(t * frame(0.0, 1.0 + 7.0/64.0, 0.0), 3.0/64.0, nil, "fin_shank_screw")
    circular_hole(t * frame(63.0/64.0, 29.0/64.0, 0.0), 3.0/64.0, nil, "fin_shank_screw")
    circular_hole(t * frame(-63.0/64.0, 29.0/64.0, 0.0), 3.0/64.0, nil, "fin_shank_screw")

    # Body mounting pilot holes
    pilot_hole(t * frame(-5.0/16.0, -5.0/16.0, 0.0), 3.0/8.0)
    pilot_hole(t * frame(5.0/16.0, 5.0/16.0, 0.0), 3.0/8.0)

    # Spoon switch bracket holes
    bottom_dimple(t * rotate(5.0) * frame(-3.0/8.0, -29.0/16.0, 0.0))
    bottom_dimple(t * rotate(5.0) * frame(-3.0/8.0, -35.0/16.0, 0.0))

    # Pop bumper
    component(t, "Pop Bumper Body")
    template(t, "Pop Bumper Solenoid")
    template(t * rotate(15.0), "Pop Bumper Spoon Switch")
  end
  
  def kickout(t)
    circular_hole(t, (1.0 + 7.0/32.0) / 2.0, nil, "mechanical")
    template(t, "Kickout_Hole_SYS7")
    
    # Kickout insert
    [-11.0/16.0, 11.0/16.0].each do |x|
        [-9.0/16, 9.0/16].each do |y|
          bottom_dimple(t * frame(x, y, 0.0))
        end
    end
    
    # Pivot bracket
    bottom_dimple(t * frame(1 + 7.0/16.0, -30.0/64.0, 0.0))
    bottom_dimple(t * frame(1 + 13.0/16.0, -30.0/64.0, 0.0))
    bottom_dimple(t * frame(1 + 15.0/16.0, 3.0/64.0, 0.0))
    bottom_dimple(t * frame(1 + 15.0/16.0, 23.0/64.0, 0.0))
      
    # Solenoid bracket
    [3 + 39.0/64.0, 4 + 7.0/64.0].each do |x|
        [39.0/64.0, 15.0/64.0].each do |y|
            bottom_dimple(t * frame(x, y, 0.0))
        end
    end
  end
  
  def post t, name=nil
    pilot_hole(t, 3.0/8.0)
    component(t, "Star_Post_1-1'16_-03-8319-13")
    component(t * Geom::Transformation.translation(Geom::Point3d.new(0, 0, 1.0 + 1.0/16.0)), "Threaded Post Screw 0001")
    p = Post.new(t)
    @posts[name] = p if name != nil
  end
  
  def post_with_tee t, name=nil
    tee_pilot_hole_6_32 t
    component(t, "Star_Post_1-1'16_-03-8319-13")
    component(t * Geom::Transformation.translation(Geom::Point3d.new(0, 0, 1.0 + 1.0/16.0)), "Threaded Post Screw 0001")
    p = Post.new(t)
    @posts[name] = p if name != nil
  end
  
  def mini_post_6_32_with_tee t
    tee_pilot_hole_6_32 t
    component(t, "Mini_Post_6-32_Thread_02-4195")
  end

  def mini_post_8_32 t
    clearance_hole_8_32 t
    component t, "Mini_Post_8-32_Thread"
  end
  
  def bumper_post t
    clearance_hole_8_32 t
    component t, "Bumper Post 8-32 Thread bottom 6-32 at Top 024056"
  end
  
  def drop_target_bank t
    round_ended_hole(t * frame(0.0, -1.0/8.0, 0.0) * rotate(90), 4.0, 0.5, nil, "mechanical")

    (-1..1).each do |i|
      mini_post_8_32(t * frame(i * (1.0 + 11.0/32.0), -9.0/16.0))
      round_insert(t * frame(i * (1.0 + 1.0/4.0), 1.0 + 3.0/32.0), 0.75)
    end    
    
    template(t * frame(0.0, 3.0/16.0), "3_bank_Sys11_Drop_Target_Bank")
    x = 1.0 + 7.0/8.0
    (1..4).each do
      y = 1.0 + 7.0/8.0
      (1..2).each do
        bottom_dimple(t * frame(x, y, 0.0))
        y -= (1.0 + 1.0/8.0)
      end
      x -= (1.0 + 1.0/4.0)
    end
  end
  
  def inline_drop_target_bank t
    template(t, "bally_inline_3_target_bank_rough")
    
    bottom_dimple(t * frame(3.0/32.0, -7.0/16.0, 0.0))
    bottom_dimple(t * frame(2.0, -7.0/16.0, 0.0))
    bottom_dimple(t * frame(7.0/8.0, 3.0 + 1.0/16.0, 0.0))
    bottom_dimple(t * frame(7.0/8.0, 1.0 + 9.0/16.0, 0.0))
    bottom_dimple(t * frame(3.0/32.0, 5.0, 0.0))
    bottom_dimple(t * frame(2.0, 5.0, 0.0))
    
    y0 = 0
    (1..3).each do
      square_hole t, -7.0/16.0, y0, 7.0/16.0, y0 + 0.5, nil, "mechanical"
      y0 += 1.5
    end
  end
  
  def inline_drop_target_bank_2 t
    template(t, "bally_inline_3_target_bank_rough_2")
    
    bottom_dimple(t * frame(3.0/32.0, (-7.0/16.0) - (1.0 + 1.0/8.0),      0.0))
    bottom_dimple(t * frame(2.0,      (-7.0/16.0) - (1.0 + 1.0/8.0),      0.0))
    bottom_dimple(t * frame(7.0/8.0,  (3.0 + 1.0/16.0) - (1.0 + 1.0/8.0), 0.0))
    bottom_dimple(t * frame(7.0/8.0,  (1.0 + 9.0/16.0) - (1.0 + 1.0/8.0), 0.0))
    bottom_dimple(t * frame(3.0/32.0, (5.0) - (1.0 + 1.0/8.0),            0.0))
    bottom_dimple(t * frame(2.0,      (5.0) - (1.0 + 1.0/8.0),            0.0))
    
    y0 = 0
    (1..3).each do
      square_hole t, -15.0/32.0, y0, 15.0/32.0, y0 + (35.0/64.0), nil, "mechanical"
      y0 += 1.5
    end
  end
  
  def sheet_guide spline
    return if cnc
    group = Sketchup.active_model.active_entities.add_group()
    
    points = []
    (0..spline.length).step(1.0/8.0) do |i|
      points.push spline.f(i)
    end
    
    edges = group.entities.add_curve points
    sheetmetalize(group, edges, 1.0+1.0/8.0, 1.0/16.0)
  end
  
  def wire_guide spline
    root_depth = 3.0/8.0
    root_radius = 5.0/128.0
    wire_radius = 6.0/128.0

    points = []
    (0..spline.length).step(1.0/8.0) do |i|
      points.push spline.f(i)
    end
    
    circular_hole(frame(points.first.x, points.first.y), root_radius, root_depth, "wireform_mount")
    circular_hole(frame(points.last.x, points.last.y), root_radius, root_depth, "wireform_mount")

    return if cnc
    
    group = Sketchup.active_model.active_entities.add_group()

    points.push Geom::Point3d.new(points.last.x, points.last.y, -root_depth)
    points.unshift Geom::Point3d.new(points.first.x, points.first.y, -root_depth)
    
    edges = group.entities.add_curve points
    wireize(group, edges, wire_radius)
  end
  
  def circle_of_pixels t, radius, count
    (0..count-1).each do |i|
      theta = i * 360.0 / count
      Sketchup.active_model.active_entities.add_cpoint t * frame(0,0,@insert_thickness - @insert_depth) * rotate(theta) * frame(radius) * Geom::Point3d.new
    end
  end
  
  def round_insert t, diameter
    if diameter == 1.5 then
      circle_of_pixels t, 5.0/8.0, 12
    elsif diameter == 1.0 then
      Sketchup.active_model.active_entities.add_cpoint t * frame(0,0,@insert_thickness - @insert_depth) * Geom::Point3d.new
      circle_of_pixels t, 3.0/8.0, 6
    else
      Sketchup.active_model.active_entities.add_cpoint t * frame(0,0,@insert_thickness - @insert_depth) * Geom::Point3d.new
    end

    radius = (diameter / 2.0) + 0.005
    
    circular_hole t, radius, @insert_depth, "insert"
    circular_hole t, radius - 1.0/16.0, nil, "insert_shelf"
    component(t * frame(0, 0, @insert_thickness - @insert_depth), "Insert 1-1`2 inch RND PL-112ROT") if diameter == 1.5
    component(t * frame(0, 0, @insert_thickness - @insert_depth), "Insert_-_1_inch_RND_PL-1ROT") if diameter == 1.0
    component(t * frame(0, 0, @insert_thickness - @insert_depth), "Insert_-_3`4_inch_RND_PL-34RAS") if diameter == 0.75
  end
  
  def triangle_insert t
    circle_of_pixels t * rotate(-30.0), 3.0/8.0, 3

    corner_radius = ((1.0/4.0) / 2.0) + 0.005
    
    zaxis = Geom::Vector3d.new(0.0, 0.0, 1.0)
    vertices = []
    2.downto(0) do |i|
      t2 = t * rotate(i * 120)
      vertices.push(t2 * Geom::Point3d.new(0.0, 69.0/128.0, 0.0))
    end
    hole = Sketchup.active_model.active_entities.add_group()
    hole_from_edges hole, round_cornered_polygon(hole, vertices, corner_radius), @insert_depth, "insert"
    hole = Sketchup.active_model.active_entities.add_group()
    hole_from_edges hole, round_cornered_polygon(hole, vertices, corner_radius - 1.0/16.0), nil, "insert_shelf"
    component(t * frame(0, 0, @insert_thickness - @insert_depth), "Insert - 1-3`16 inch Tri PI-1316TOS")
  end
  
  def small_arrow_insert t
    Sketchup.active_model.active_entities.add_cpoint t * frame(0,0,@insert_thickness - @insert_depth) * Geom::Point3d.new

    width = 21.0/32.0
    height = 1.0 + 65.0/128.0
    corner_radius = 9.0/64.0 + 0.005
    
    vertices = []
    vertices.push(t * Geom::Point3d.new(-(width/2.0 - corner_radius), corner_radius, 0.0))
    vertices.push(t * Geom::Point3d.new(0.0, height - corner_radius, 0.0))
    vertices.push(t * Geom::Point3d.new((width/2.0 - corner_radius), corner_radius, 0.0))
    hole = Sketchup.active_model.active_entities.add_group()
    hole_from_edges hole, round_cornered_polygon(hole, vertices, corner_radius), @insert_depth, "insert"
    hole = Sketchup.active_model.active_entities.add_group()
    hole_from_edges hole, round_cornered_polygon(hole, vertices, corner_radius - 1.0/16.0), nil, "insert_shelf"
    component(t * frame(0, 0, @insert_thickness - @insert_depth), "Insert 1-1'2 inch Triangle PI-112TGT")
  end
  
  def large_arrow_insert t
    (0..7).each do |i|
      Sketchup.active_model.active_entities.add_cpoint t * frame(0, 1.0/8.0 + i*1.0/4.0, @insert_thickness - @insert_depth) * Geom::Point3d.new
    end
    
    width = 1.0 + 1.0/64.0
    height = 2.0 + 1.0/64.0
    corner_radius = 12.0/64.0 + 0.005
    
    vertices = []
    vertices.push(t * Geom::Point3d.new(-(width/2.0 - corner_radius), corner_radius, 0.0))
    vertices.push(t * Geom::Point3d.new(0.0, height - corner_radius, 0.0))
    vertices.push(t * Geom::Point3d.new((width/2.0 - corner_radius), corner_radius, 0.0))
    hole = Sketchup.active_model.active_entities.add_group()
    hole_from_edges hole, round_cornered_polygon(hole, vertices, corner_radius), @insert_depth, "insert"
    hole = Sketchup.active_model.active_entities.add_group()
    hole_from_edges hole, round_cornered_polygon(hole, vertices, corner_radius - 1.0/16.0), nil, "insert_shelf"
    component(t * frame(0, 0, @insert_thickness - @insert_depth), "Insert 2 inch Arrow PI-T2RT")
  end

  def small_oval_insert t
    Sketchup.active_model.active_entities.add_cpoint t * frame(0,0,@insert_thickness - @insert_depth) * Geom::Point3d.new

    width = 1.0 + 5.0/8.0
    height = 3.0/4.0
    corner_radius = (height / 2.0) + 0.005
  
    vertices = []
    vertices.push(t * Geom::Point3d.new(-(width - height)/2.0, 0.0, 0.0))
    vertices.push(t * Geom::Point3d.new((width - height)/2.0, 0.0, 0.0))
    hole = Sketchup.active_model.active_entities.add_group()
    hole_from_edges hole, round_cornered_polygon(hole, vertices, corner_radius), @insert_depth, "insert"
    hole = Sketchup.active_model.active_entities.add_group()
    hole_from_edges hole, round_cornered_polygon(hole, vertices, corner_radius - 1.0/16.0), nil, "insert_shelf"
    insert = component(t * frame(0, 0, @insert_thickness - @insert_depth), "Insert - 1-5`8 inch OVAL PI-11234--OGT")
  end
  
  def large_oval_insert t
    (0..7).each do |i|
      Sketchup.active_model.active_entities.add_cpoint t * frame(-7.0/8.0) * frame(i * 1.0/4.0,0,@insert_thickness - @insert_depth) * Geom::Point3d.new
    end
    
    width = 2.0 + 6.0/16.0
    height = 3.0/4.0
    corner_radius = (height / 2.0) + 0.005
    
    vertices = []
    vertices.push(t * Geom::Point3d.new(-(width - height)/2.0, 0.0, 0.0))
    vertices.push(t * Geom::Point3d.new((width - height)/2.0, 0.0, 0.0))
    hole = Sketchup.active_model.active_entities.add_group()
    hole_from_edges hole, round_cornered_polygon(hole, vertices, corner_radius), @insert_depth, "insert"
    hole = Sketchup.active_model.active_entities.add_group()
    hole_from_edges hole, round_cornered_polygon(hole, vertices, corner_radius - 1.0/16.0), nil, "insert_shelf"
  end
  
  def fixed_target t
    round_ended_hole(t * rotate(90), 1.0 + 1.0/8.0, 0.5, nil, "mechanical")
    component(t * frame(0.0, -4.0/16.0, -@floor_thickness) * rotate(180), "Target 004 Assy")
    bottom_dimple(t * frame(-3.0/16.0, -9.0/16.0))
    bottom_dimple(t * frame(+3.0/16.0, -9.0/16.0))
  end
end

class UpperPlayfield < Playfield
  attr_reader :x_offset, :y_offset, :z_offset
  
  def initialize(parent)
    @floor = Sketchup.active_model.active_entities.add_group()
    
    @floor_width = 9.0
    @floor_depth = 6.0 + 3.0/4.0
    @floor_thickness = 1.0/4.0
    @gap = 1.0/2.0
    
    @wall_height = 1.125
    @wall_thickness = 0.5
    
    @x_offset = 0.0
    @y_offset = parent.floor_depth - @floor_depth
    @z_offset = parent.wall_height + @gap + @floor_thickness
    
    @posts = Hash.new
  end
end
