class RadiusDropdown
  constructor: () ->
    @elem = $ HandlebarsTemplates['explore/map_controls/radius_dropdown']()
    # @elem.find("#radiusdropdown").focus (e) -> $(e.target).blur()

  val: () ->
    parseInt(@elem.find("#radiusdropdown").val())

  control: () ->
    @elem[0]

  addTempRadius: (val) ->
    @resetTempRadius()
    val = parseInt(val)

    if @elem.find("#radiusdropdown option[value=#{val}]").length == 0
      textVal = val
      if val > 1000
        fixed = if val < 10000 then 1 else 0
        textVal = (val /1000.0).toFixed(fixed) + " km"
      else
        textVal += " m"

      @elem.find("#radiusdropdown").append("<option class='tempradius' value='#{val}'>#{textVal}</option>")
      options = @elem.find("#radiusdropdown option").detach()
      options.sort( (a,b) -> a.value - b.value)
      @elem.find("#radiusdropdown").append(options)

    @elem.find("#radiusdropdown").val(val)

  resetTempRadius: () ->
    @elem.find(".tempradius").remove()


window.RadiusDropdown = RadiusDropdown
