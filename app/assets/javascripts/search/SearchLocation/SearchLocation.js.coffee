class SearchLocation
  @overlays = null

  # Returns an array of mappable items that need to have .setMap(map) called
  # on them to display
  mapOverlays: () ->
    []

  activateMapOverlay: () ->

  clear: () ->
    overlay.setMap(null) for overlay in @mapOverlays()

  @deserialize: (values) ->
    values.containsKeys = (keys) ->
      for k in keys
        return false unless values.hasOwnProperty k
      true

    type = switch
      when values.containsKeys ['ll', 'radius']
        CenterRadiusSearchLocation
      when values.containsKeys ['ne', 'sw']
        BoundingBoxSearchLocation
      when values.containsKeys ['near']
        NearGeoLocation
      when values.containsKeys ['polygon']
        PolygonSearchLocation
      when values.containsKeys ['global']
        GlobalLocation
      else
        GlobalLocation
    type.deserialize(values)

  @parseLatLng: (str) ->
    # Expects a comma separated lat lng and returns a google.maps.LatLng
    # value, or throws an exception if the lat lng was not valid
    [lat, lng] = str.split(',').map (e) -> parseFloat(e)
    unless (lat >= -90.0 and lat <= 90.0) and (lng >= -180.0 and lng <=180.0)
      throw "Deserialization Problem: latlng not in range"
    new google.maps.LatLng(lat, lng)


window.SearchLocation = SearchLocation
