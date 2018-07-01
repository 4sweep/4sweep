#= require search/VenueActionPopovers/VenueActionPopover

class RefreshAction extends VenueActionPopover
  requireSelectedCount: 1
  tooltipTitle: () -> "Reload extended venue details"

  attach: () ->
    # Don't call super
    @trigger.click (e) =>
      e.preventDefault()
      for own venueid, venueelement of @explorer.selected
        do (venueelement) ->
          lid = venueelement.venueresult.listeners.add "pulling-full-done", () ->
            venueelement.toggleSelection(false)
            venueelement.venueresult.listeners.remove "pulling-full-done", lid
        venueelement.venueresult.refreshEverything(true)
window.RefreshAction = RefreshAction
