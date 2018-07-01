class NearGeoLocation extends SearchLocation
  renderable: () -> false

  constructor: (@geoString) ->

  values: () ->
    near: @geoString

  serialize: () ->
    'near': @geoString

  @deserialize: (values) ->
    new NearGeoLocation(values['near'])

  display: (controls) ->
    controls.nearControl?.show(@geoString)
    return () ->

  fitMapToLocation: (map) ->
    # This is not a mappable location, so we'll make this a NO-OP

window.NearGeoLocation = NearGeoLocation
