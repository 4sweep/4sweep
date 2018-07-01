class FitButtons
  constructor: (@explorer, @map) ->
    buttons = $ HandlebarsTemplates['explore/map_controls/fit_buttons']()
    @map.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push(buttons[0])
    buttons.find(".fit-venues").click (e) =>
      e.preventDefault()
      bounds = @explorer.results?.resultsBounds()
      bounds = bounds.union(@explorer.pinnedResults.pinnedBounds())
      @map.fitBounds(bounds) unless bounds.isEmpty()

    buttons.find(".fit-searchlocation").click (e) =>
      e.preventDefault()
      @explorer.lastSearch?.location.fitMapToLocation(@map)

window.FitButtons = FitButtons
