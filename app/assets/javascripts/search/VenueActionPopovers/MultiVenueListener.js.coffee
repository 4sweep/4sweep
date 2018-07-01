#= require search/SubmitListener

class MultiVenueListener extends SubmitListener
  constructor: (selectedvenues) ->
    @venues = $.extend({}, selectedvenues) # Clone venues

  objectType: () -> "venues"
  processSubmit: (flag) ->
    @venues[flag.venueId]?.venueresult.markFlagged(flag)
    @venues[flag.secondaryVenueId]?.venueresult.markFlagged(flag)

  processUndo: (flag) ->
    @venues[flag.venueId]?.venueresult.undoMarkedFlagged(flag)
    @venues[flag.secondaryVenueId]?.venueresult.undoMarkedFlagged(flag)

  processReselect: () ->
    for id, venue of @venues
      venue.toggleSelection()

window.MultiVenueListener = MultiVenueListener
