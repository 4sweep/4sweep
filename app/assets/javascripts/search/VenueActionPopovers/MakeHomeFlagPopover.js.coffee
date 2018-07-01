#= require search/VenueActionPopovers/VenueFlagPopover
class MakeHomeFlagPopover extends VenueFlagPopover
  template: "explore/massflags/makehome"
  tooltipTitle: () -> "Change Category to Home"
  title: () ->
    "Re-categorize <span class='selectedcount'>#{@selectedcount}</span> place(s) as home:</span>"

  requiresExtraConfirmation: (flags = [], selected) ->
    @requiresExtraConfirmationOnDistinctUsers(flags, selected, 15)

window.MakeHomeFlagPopover = MakeHomeFlagPopover
