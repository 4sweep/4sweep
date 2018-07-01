#= require search/VenueActionPopovers/VenueFlagPopover
class MakePrivateFlagPopover extends VenueFlagPopover
  template: "explore/massflags/makeprivate"
  tooltipTitle: () -> "Make Venue Private"
  title: () ->
    "Mark <span class='selectedcount'>#{@selectedcount}</span> place(s) private:"

  requiresExtraConfirmation: (flags = [], selected) ->
    @requiresExtraConfirmationOnDistinctUsers(flags, selected, 15)

window.MakePrivateFlagPopover = MakePrivateFlagPopover
