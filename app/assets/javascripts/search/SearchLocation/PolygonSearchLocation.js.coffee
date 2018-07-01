class PolygonSearchLocation extends SearchLocation
  divisible: true
  bounded: true

  renderable: () -> true

  constructor: (@points) ->
    @latLngBounds = new google.maps.LatLngBounds()
    for p in @points
      @latLngBounds.extend(p)

    @polygon = new google.maps.Polygon
      path: @points

  values: (options = {}) ->
    ne = @latLngBounds.getNorthEast()
    sw = @latLngBounds.getSouthWest()

    if options.asLlBounds
      "#{ne.lat()},#{ne.lng()},#{sw.lat()},#{sw.lng()}"
    else
      ne: "#{ne.lat()},#{ne.lng()}"
      sw: "#{sw.lat()},#{sw.lng()}"

  getCenter: () ->
    @latLngBounds().getCenter()

  bounds: () ->
    @latLngBounds

  fitMapToLocation: (map) ->
    map.fitBounds(@bounds())

  serialize: () ->
    polygon: (@points.map (point) -> point.lat().toFixed(6) + "," + point.lng().toFixed(6)).join(";")

  @deserialize: (values) ->
    path = []
    for point in values['polygon'].split(';')
      [lat, lng] = point.split(',')
      path.push new google.maps.LatLng(lat,lng)

    new PolygonSearchLocation(path)

  mapOverlays: (extras = {}) ->
    return @overlays if @overlays
    poly = @drawingWithOptions $.extend
      strokeWeight: 1
      editable: false
      fillOpacity: 0.1
      strokeOpacity: 0.2
      zIndex: 1
      editable: false
      draggable: false
      clickable: false
    , extras
    @overlays = [poly]

  drawingWithOptions: (options = {}) ->
    new google.maps.Polygon $.extend
      paths: @points
    , options

  display: (controls) ->
    poly = @drawingWithOptions({map: controls.map})
    return () -> poly.setMap(null)

  intersectsRectangle: (boundingbox) ->
    bounds = boundingbox.bounds()
    [lat_lo,lng_lo,lat_hi,lng_hi] = [bounds.getSouthWest().lat(), bounds.getSouthWest().lng(),
                                     bounds.getNorthEast().lat(), bounds.getNorthEast().lng()]

    corners = [new google.maps.LatLng(lat_lo, lng_lo), new google.maps.LatLng(lat_hi, lng_lo),
               new google.maps.LatLng(lat_hi, lng_hi), new google.maps.LatLng(lat_lo, lng_hi)]

    # first, if any of the corners are inside the polygon, we know we intersect
    for corner in corners
      return true if @containsPoint(corner)

    # next, if none of the corners are in the polygon, we still must test to see if
    # the polygon exists within the rectangle by checking for line intersections:
    for i in [0...@points.length]
      for j in [0...corners.length]
        return true if @linesIntersect(corners[j], corners[(j+1)%corners.length],
                                       @points[i], @points[(i+1)%@points.length])

    false

  containsPoint: (point) ->
    google.maps.geometry.poly.containsLocation(point, @polygon)

  # From http://stackoverflow.com/questions/9043805/test-if-two-lines-intersect-javascript-function/16725715#16725715
  ccw: (p1, p2, p3) ->
    a = p1.lng(); b = p1.lat();
    c = p2.lng(); d = p2.lat();
    e = p3.lng(); f = p3.lat();
    (f - b) * (c - a) > (d - b) * (e - a);

  linesIntersect: (p1, p2, p3, p4) ->
    return (@ccw(p1, p3, p4) != @ccw(p2, p3, p4)) && (@ccw(p1, p2, p3) != @ccw(p1, p2, p4));

window.PolygonSearchLocation = PolygonSearchLocation
