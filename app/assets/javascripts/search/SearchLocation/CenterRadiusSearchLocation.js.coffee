class CenterRadiusSearchLocation extends SearchLocation
  divisible: true
  bounded: true

  renderable: () -> true

  constructor: (@center, @radius) ->

  values: () ->
    ll: "#{@center.lat()},#{@center.lng()}"
    radius: @radius

  mapOverlays: () ->
    return @overlays if @overlays

    circle = @drawingWithOptions
      strokeWeight: 1
      fillOpacity: 0.05
      editable: false
      clickable: false

    centerMarker = new google.maps.Marker
      position: @center
      icon: '/img/dot.png'
      zIndex: 10

    @overlays = [circle, centerMarker]

  serialize: () ->
    ll: "#{@center.lat().toFixed(6)},#{@center.lng().toFixed(6)}"
    radius: @radius.toFixed(0)

  getCenter: () ->
    @center

  fitMapToLocation: (map) ->
    map.fitBounds(@bounds())

  bounds: () ->
    new google.maps.Circle
      center: @center
      radius: @radius
    .getBounds()

  extendToRadius: (newRadius) ->
    new CenterRadiusSearchLocation(@center, newRadius)

  drawingWithOptions: (options = {}) ->
    new google.maps.Circle $.extend
      center: @center
      radius: @radius
    , options

  @deserialize: (values) ->
    new CenterRadiusSearchLocation(SearchLocation.parseLatLng(values['ll']), parseInt(values['radius']))

  intersectsRectangle: (boundingbox) ->
    bounds = boundingbox.bounds()
    [lat_lo,lng_lo,lat_hi,lng_hi] = [bounds.getSouthWest().lat(), bounds.getSouthWest().lng(),
                                     bounds.getNorthEast().lat(), bounds.getNorthEast().lng()]

    # if any of the corners of this rectangle are less than radius away from the center,
    # return true

    corners = [new google.maps.LatLng(lat_lo, lng_lo), new google.maps.LatLng(lat_hi, lng_lo),
               new google.maps.LatLng(lat_hi, lng_hi), new google.maps.LatLng(lat_lo, lng_hi)]

    for corner in corners
      return true if @containsPoint(corner)

    false

  display: (controls) ->
    circle = @drawingWithOptions({map: controls.map})
    controls.radiusControl.addTempRadius(@radius)
    return () -> circle.setMap(null)

  containsPoint: (point) ->
    google.maps.geometry.spherical.computeDistanceBetween(@center, point) <= @radius

window.CenterRadiusSearchLocation = CenterRadiusSearchLocation
