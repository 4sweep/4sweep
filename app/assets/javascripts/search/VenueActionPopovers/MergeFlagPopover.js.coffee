#= require search/VenueActionPopovers/VenueFlagPopover
class MergeFlagPopover extends VenueFlagPopover
  requireSelectedCount: 2
  template: "explore/massflags/merge"
  tooltipTitle: () -> "Flag as Duplicate"
  title: () ->
    "Mark <span class='selectedcount'>#{@selectedcount}</span> places as duplicates:"

  createFlags: () ->
    maxCheckinVenue = @maxCheckinVenue()
    for venueid, venueelement of @explorer.selected when venueid isnt maxCheckinVenue.id
      flag = maxCheckinVenue.createMergeFlag venueelement.venueresult, @flagExtras()

  contentExtras: () ->
    d = @maxSelectedDistance()

    maxDistance: Math.round(d)
    venueCount: (a for a,b of @explorer.selected).length
    warnClass: switch
      when d > 10000 then 'danger'
      when d > 1000 then 'warning'
      else 'info'

  updatedSelectedCount: (count, popover) ->
    super(count, popover)

    # Also, update the distance, if available
    popoverelement = $(popover.trigger).data('popover')?.tip()
    popoverelement?.find('.distancewarning').html(
      Handlebars.partials['explore/massflags/_merge_distance_warning'](@contentExtras())
    )

  maxCheckinVenue: () ->
    (venueelement.venueresult for venueid, venueelement of @explorer.selected).reduce (a, b) ->
      if a.venuedata.stats.checkinsCount > b.venuedata.stats.checkinsCount then a else b

  maxSelectedDistance: () ->
    return 0 if (venueid for own venueid, venueelem of @explorer.selected).length < 2
    target = @maxCheckinVenue()


    distances = (venueelement.venueresult for venueid, venueelement of @explorer.selected when venueid != target.id)
      .map (venueresult) -> target.distanceFromPoint(venueresult.position())

    Math.max distances...

  requiresExtraConfirmation: (flags = []) ->
    if flags.length >= 5
      return ["You are requesting to <strong>merge #{flags.length + 1}</strong> different venues together." +
              "  Please triple check that these venues are EXACT duplicates and are not subvenues."]
    return false

window.MergeFlagPopover = MergeFlagPopover
