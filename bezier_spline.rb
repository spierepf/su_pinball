# Shawn Wilson Feb 2016
# BezierSpline is based on code at http://www.codeproject.com/Articles/31859/Draw-a-Smooth-Curve-through-a-Set-of-D-Points-wit
# originally written by Oleg V. Polikarpotchkin and Peter Lee
# Adapted to Ruby by Shawn Wilson Feb 2016
# Bezier Spline methods

class BezierSpline
  def self.fromEdges(edges)
    knots = []
    edges.each { |edge| knots += [edge.start.position] }
    knots += [edges.last.end.position]
    BezierSpline.new(knots)
  end
  
  # <summary>
  # Get open-ended Bezier Spline Control Points.
  # </summary>
  # <param name="knots">Input Knot Bezier spline points.</param>
  # <param name="firstControlPoints">Output First Control points array of knots.Length - 1 length.</param>
  # <param name="secondControlPoints">Output Second Control points array of knots.Length - 1 length.</param>
  # <exception cref="ArgumentNullException"><paramref name="knots"/> parameter must be not null.</exception>
  # <exception cref="ArgumentException"><paramref name="knots"/> array must containg at least two points.</exception>
  def initialize(knots)
    raise "knots is nil" if knots == nil 
    n = knots.length - 1
    raise "At least two knot points required" if (n < 1) 
    @knots = knots

    if (n == 1)
      # Special case: Bezier curve should be a straight line.
      # 3P1 = 2P0 + P3
      @firstControlPoints = [Geom::Point3d.new((2.0 * knots[0].x + knots[1].x) / 3.0, (2.0 * knots[0].y + knots[1].y) / 3.0, (2.0 * knots[0].z + knots[1].z) / 3.0)]

      # P2 = 2P1 – P0
      @secondControlPoints = [Geom::Point3d.new(2.0 * firstControlPoints[0].x - knots[0].x, 2.0 * firstControlPoints[0].y - knots[0].y, 2.0 * firstControlPoints[0].z - knots[0].z)]
      return
    end

    # Calculate first Bezier control points
    # Right hand side vector
    rhs = []
    
    # Set right hand side X values
    1.upto(n-2) do |i|
      rhs[i] = 4 * knots[i].x + 2 * knots[i + 1].x
    end
    rhs[0] = knots[0].x + 2 * knots[1].x
    rhs[n - 1] = (8 * knots[n - 1].x + knots[n].x) / 2.0
    # Get first control points X-values
    x = initFirstControlPoints(rhs)
    
    # Set right hand side Y values
    1.upto(n-2) do |i|
      rhs[i] = 4 * knots[i].y + 2 * knots[i + 1].y
    end
    rhs[0] = knots[0].y + 2 * knots[1].y
    rhs[n - 1] = (8 * knots[n - 1].y + knots[n].y) / 2.0
    # Get first control points Y-values
    y = initFirstControlPoints(rhs)
    
    # Set right hand side Z values
    1.upto(n-2) do |i|
      rhs[i] = 4 * knots[i].z + 2 * knots[i + 1].z
    end
    rhs[0] = knots[0].z + 2 * knots[1].z
    rhs[n - 1] = (8 * knots[n - 1].z + knots[n].z) / 2.0
    # Get first control points Z-values
    z = initFirstControlPoints(rhs)
    
    # Fill output arrays.
    @firstControlPoints = []
    @secondControlPoints = []
    0.upto(n-1) do |i|
      # First control point
      @firstControlPoints += [Geom::Point3d.new(x[i], y[i], z[i])]
      # Second control point
      if (i < n - 1) then
        @secondControlPoints += [Geom::Point3d.new(2 * knots[i + 1].x - x[i + 1], 2 * knots[i + 1].y - y[i + 1], 2 * knots[i + 1].z - z[i + 1])]
      else
        @secondControlPoints += [Geom::Point3d.new((knots[n].x + x[n - 1]) / 2, (knots[n].y + y[n - 1]) / 2, (knots[n].z + z[n - 1]) / 2)]
      end
    end
  end
  
  # <summary>
  # Solves a tridiagonal system for one of coordinates (x or y) of first Bezier control points.
  # </summary>
  # <param name="rhs">Right hand side vector.</param>
  # <returns>Solution vector.</returns>
  def initFirstControlPoints(rhs)
    n = rhs.length
    x = [] # Solution vector.
    tmp = [] # Temp workspace.
  
    b = 2.0
    x[0] = rhs[0] / b
    1.upto(n-1) do |i| # Decomposition and forward substitution.
      tmp[i] = 1 / b
      b = (i < n - 1 ? 4.0 : 3.5) - tmp[i]
      x[i] = (rhs[i] - x[i - 1]) / b
    end
    1.upto(n-1) do |i|
      x[n - i - 1] -= tmp[n - i] * x[n - i] # Backsubstitution.
    end
    
    x
  end
  
  private :initFirstControlPoints
  
  def f(t)
    return @knots[0] if t <= 0
    return @knots[length] if t >= length
    
    ti = t.floor
    tf = t - ti
    
    p0 = @knots[ti]
    p1 = @firstControlPoints[ti]
    p2 = @secondControlPoints[ti]
    p3 = @knots[ti+1]
    
    cX = 3.0 * (p1.x - p0.x)
    bX = 3.0 * (p2.x - p1.x) - cX
    aX = p3.x - p0.x - cX - bX
  
    cY = 3.0 * (p1.y - p0.y)
    bY = 3.0 * (p2.y - p1.y) - cY
    aY = p3.y - p0.y - cY - bY
  
    cZ = 3.0 * (p1.z - p0.z)
    bZ = 3.0 * (p2.z - p1.z) - cZ
    aZ = p3.z - p0.z - cZ - bZ
    
    x = (aX * (tf ** 3)) + (bX * (tf ** 2)) + (cX * tf) + p0.x
    y = (aY * (tf ** 3)) + (bY * (tf ** 2)) + (cY * tf) + p0.y
    z = (aZ * (tf ** 3)) + (bZ * (tf ** 2)) + (cZ * tf) + p0.z
  
    Geom::Point3d.new(x,y,z)
  end
  
  def length
    @knots.length - 1
  end
  
  def axis(t)
    delta = 0.1
    p0 = t > delta ? f(t - delta) : f(0)
    p2 = (t + delta) < length ? f(t + delta) : f(length)
    (p0 - p2).normalize!
  end
  
  def frame(t)
    yaxis = axis(t)
    xaxis = (yaxis * Geom::Vector3d.new(0, 0, 1)).normalize!
    zaxis = xaxis * yaxis
    Geom::Transformation.axes(f(t), xaxis, yaxis, zaxis) 
  end
end
