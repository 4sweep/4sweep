class NearButton
  constructor: () ->
    @elem = $ HandlebarsTemplates['explore/map_controls/near_button']()
    @elem.click (e) =>
      e.preventDefault()
      @open()
      @focus()
    @elem.find("input").keyup (e) =>
      if e.keyCode == 13 #enter
        @elem.find(".executeNear").trigger("click")

  control: () ->
    @elem[0]

  focus: () ->
    @elem.find("input").focus()

  getGeoLocation: () ->
    new NearGeoLocation(@elem.find("input.nearString").val().trim())

  close: () ->
    @elem.find(".nearInput").addClass("hide")
    @elem.addClass("closed").removeClass("open")

  open: () ->
    @elem.find(".nearInput").removeClass("hide")
    @elem.removeClass("closed").addClass("open")

  setGeocode: (geocode) ->
    @elem.find("input").val(geocode.feature.displayName)

  show: (val) ->
    @elem.find("input").val(val)
    @open()

window.NearButton = NearButton
