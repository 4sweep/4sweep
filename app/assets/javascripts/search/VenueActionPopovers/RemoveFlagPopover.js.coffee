class RemoveFlagPopover extends VenueFlagPopover
  template: "explore/massflags/removevenue"
  tooltipTitle: () -> "Flag to Remove Venue"
  title: () ->
    "Remove <span class='selectedcount'>#{@selectedcount}</span> place(s):"
  showPopover: (e) ->
    super(e)

    # Remove flag popovers have a link encouraging people to
    # make venues private instead:
    popover = $(e).data('popover')?.tip()
    popover.find(".privateflag").click (e) ->
      e.preventDefault()
      $(".mass-private").click()

  requiresExtraConfirmation: (flags = [], selected) ->
    result = []

    for venueid, venueelement of selected when venueelement.venueresult.venuedata.stats.usersCount > 15
      venuedata = venueelement.venueresult.venuedata
      result.push "Venue <strong>#{venuedata.name}</strong> has been visited by <strong>#{venuedata.stats.usersCount}</strong> distinct users."

    if result.length > 0 then result else false
window.RemoveFlagPopover = RemoveFlagPopover
