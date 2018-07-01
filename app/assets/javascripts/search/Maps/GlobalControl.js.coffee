class GlobalControl
  constructor: () ->
    @elem = $ HandlebarsTemplates['explore/map_controls/global']()

  control: () ->
    @elem[0]

  reset: () ->
    @elem.removeClass('clicked')

  select: () ->
    @elem.addClass('clicked')

window.GlobalControl = GlobalControl
