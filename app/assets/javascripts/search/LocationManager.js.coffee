class LocationManager
  constructor: (@map, @lastSearchLocation) ->
    # Set up listeners
    # Set up map elements and listeners on them
    @setupDrawing();
    unless @lastSearchLocation instanceof GlobalLocation
      @lastFiniteLocation = @lastSearchLocation
    @lastBoundedLocation = @lastSearchLocation if @lastSearchLocation.bounded

  setupDrawing: () ->
    @setupDrawingModes()
    @globalControl = new GlobalControl();
    @radiusControl = new RadiusDropdown()
    @nearControl = new NearButton()

    @radiusControl.elem.change (e) =>
      e.preventDefault()
      radius = @radiusControl?.val() || 25000
      extended = @lastBoundedLocation.extendToRadius(radius)
      shape = extended.drawingWithOptions({map: @map})
      @processLocationDraw(extended, shape)
      @globalControl.reset()
      @nearControl.close()

    @nearControl.elem.find("button.executeNear").click (e) =>
      e.preventDefault()
      @processLocationDraw(@nearControl.getGeoLocation())

    @globalControl.elem.children('div').on 'click', (e) =>
      @globalControl.select()
      @drawingManager.setDrawingMode(null)
      @processLocationDraw(new GlobalLocation())
      @nearControl.close()

    google.maps.event.addListener @map, "click", (event) =>
      radius = @radiusControl.val()
      circle = new google.maps.Circle($.extend @circleOpts, {radius: radius, center: event.latLng, map: @map})
      @processLocationDraw(new CenterRadiusSearchLocation(event.latLng, radius), circle)
      @globalControl.reset()

  setupDrawingModes: (options = []) ->
    @drawingManager?.setMap(null)
    @map.controls[google.maps.ControlPosition.TOP_LEFT].clear()
    drawingModes = []
    drawingModes.push google.maps.drawing.OverlayType.RECTANGLE if "box" in options
    drawingModes.push google.maps.drawing.OverlayType.CIRCLE if "circle" in options
    drawingModes.push google.maps.drawing.OverlayType.POLYGON if "polygon" in options

    @drawingManager = new google.maps.drawing.DrawingManager
      map: @map
      drawingMode: null
      drawingControlOptions:
        drawingModes: drawingModes
      drawingControl: true
      rectangleOptions:
        strokeWeight: 1
        editable: false
        fillOpacity: 0.2
        strokeOpacity: 0.2
        fillColor: "#FFFF00"
        zIndex: 1
        clickable: false
      circleOptions:
        fillOpacity: 0.05
        editable: false
        clickable: false
        strokeWeight: 1
        fillColor: "#FFFF00"

    google.maps.event.addListener @drawingManager, "drawingmode_changed", (e) =>
      @globalControl.reset()
      @nearControl.close()
      # if @drawingManager.drawingMode == 'rectangle'
      #   @radiusControl.elem.hide()
      # else
      #   @radiusControl.elem.show()

    if "box" in options
      google.maps.event.addListener @drawingManager, 'rectanglecomplete', (rectangle) =>
        boxLocation = new BoundingBoxSearchLocation(rectangle.getBounds().getNorthEast(), rectangle.getBounds().getSouthWest())
        @radiusControl.addTempRadius(boxLocation.radius())
        @processLocationDraw(boxLocation, rectangle)
        @nearControl.close()

    if "circle" in options
      google.maps.event.addListener @drawingManager, 'circlecomplete', (circle) =>
        radius = circle.getRadius()
        @radiusControl.addTempRadius(radius)
        @processLocationDraw(new CenterRadiusSearchLocation(circle.getCenter(), circle.getRadius()), circle)
        @nearControl.close()
      @map.controls[google.maps.ControlPosition.TOP_LEFT].push(@radiusControl.control())

    if "polygon" in options
      google.maps.event.addListener @drawingManager, 'polygoncomplete', (polygon) =>
        @processLocationDraw(new PolygonSearchLocation(polygon.getPath().getArray()), polygon)
        @nearControl.close()

    if "global" in options
      @map.controls[google.maps.ControlPosition.TOP_LEFT].push(@globalControl.control())

    if "near" in options
      @map.controls[google.maps.ControlPosition.TOP_LEFT].push(@nearControl.control())

  setGlobal: () ->
    @lastSearchLocation = new GlobalLocation()
    @globalControl.select()
    @drawingManager.setDrawingMode(null)

  processLocationDraw: (location, shape = undefined) ->
    @lastSearchLocation.clear()
    @lastFiniteLocation?.clear()

    @lastSearchLocation = location
    @lastFiniteLocation = location unless location instanceof GlobalLocation
    @lastBoundedLocation = location if location.bounded
    search = @activeTab.performSearchAt @lastSearchLocation
    search.listeners.add 'resultsready geotoobig searchfailed', () ->
      shape?.setMap(null)

    if location instanceof NearGeoLocation
      search.listeners.add 'searchgeocoded', (geocode) =>
        @nearControl.setGeocode(geocode)
        @lastBoundedLocation = new BoundingBoxSearchLocation(
          new google.maps.LatLng(geocode.feature.geometry.bounds.ne.lat, geocode.feature.geometry.bounds.ne.lng),
          new google.maps.LatLng(geocode.feature.geometry.bounds.sw.lat, geocode.feature.geometry.bounds.sw.lng)
        )

  displaySearchLocation: (search) ->
    location = search.location
    @lastSearchLocation = location
    @lastFiniteLocation = location unless location instanceof GlobalLocation
    @lastBoundedLocation = location if location.bounded

    clearFunction = location.display
      map: @map
      nearControl: @nearControl
      globalControl: @globalControl
      radiusControl: @radiusControl

    search.listeners.add 'resultsready geotoobig searchfailed', () ->
      clearFunction()

  showControls: (actions) ->
    @setupDrawingModes(actions)

  location: (finiteOnly) ->
    # This is the location currently selected on the map
    if finiteOnly then @lastFiniteLocation else @lastSearchLocation

  setActiveTab: (@activeTab) ->

window.LocationManager = LocationManager
