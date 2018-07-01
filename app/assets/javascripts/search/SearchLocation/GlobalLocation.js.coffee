class GlobalLocation extends SearchLocation
  renderable: () -> false

  activateMapOverlay: () ->
    # This might be a bit hacky:
    $(".globalButton").addClass("clicked")

  asLlBounds: () ->
    null

  values: () ->
    {}

  serialize: () ->
    {global: "global"}

  @deserialize: () ->
    new GlobalLocation()

  display: (controls) ->
    controls.globalControl?.select()
    return () ->

  fitMapToLocation: (map) ->
    worldBounds = new google.maps.LatLngBounds(new google.maps.LatLng(-85,-180),
                                               new google.maps.LatLng(85,180))
    map.fitBounds(worldBounds)

window.GlobalLocation = GlobalLocation
