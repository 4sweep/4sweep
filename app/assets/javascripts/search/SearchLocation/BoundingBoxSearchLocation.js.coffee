class BoundingBoxSearchLocation extends SearchLocation
  divisible: true
  bounded: true

  renderable: () -> true
  constructor: (@ne, @sw) ->

  values: (options = {}) ->
    if options.asLlBounds
      llBounds: @asLlBounds()
    else
      ne: "#{@ne.lat()},#{@ne.lng()}"
      sw: "#{@sw.lat()},#{@sw.lng()}"

  asLlBounds: () ->
    "#{@ne.lat()},#{@ne.lng()},#{@sw.lat()},#{@sw.lng()}"

  mapOverlays: (extras = {}) ->
    return @overlays if @overlays
    rect = @drawingWithOptions $.extend
      strokeWeight: 1
      editable: false
      fillOpacity: 0.1
      strokeOpacity: 0.2
      zIndex: 1
      editable: false
      draggable: false
      clickable: false
    , extras
    @overlays = [rect]

  getCenter: () ->
    @bounds().getCenter()

  bounds: () ->
     new google.maps.LatLngBounds(@sw, @ne)

  fitMapToLocation: (map) ->
    map.fitBounds(@bounds())

  @deserialize: (values) ->
    new BoundingBoxSearchLocation(SearchLocation.parseLatLng(values['ne']), SearchLocation.parseLatLng(values['sw']))

  drawingWithOptions: (options = {}) ->
    new google.maps.Rectangle $.extend
      bounds: @bounds()
    , options

  extendToRadius: (newRadius) ->
    new BoundingBoxSearchLocation(
      google.maps.geometry.spherical.computeOffset(@getCenter(), newRadius, 135),
      google.maps.geometry.spherical.computeOffset(@getCenter(), newRadius, 315)
    )

  serialize: () ->
    ne: "#{@ne.lat().toFixed(6)},#{@ne.lng().toFixed(6)}"
    sw: "#{@sw.lat().toFixed(6)},#{@sw.lng().toFixed(6)}"

  radius: () ->
    # for a box, we're giving the radius of the smallest circle that contains the
    # rectangle
    google.maps.geometry.spherical.computeDistanceBetween(@ne, @getCenter())

  display: (controls) ->
    box = @drawingWithOptions({map: controls.map})
    controls.radiusControl.addTempRadius(@radius())
    return () ->
      box.setMap(null)

window.BoundingBoxSearchLocation = BoundingBoxSearchLocation
