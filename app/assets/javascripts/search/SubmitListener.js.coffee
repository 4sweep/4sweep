class SubmitListener
  objectType: () ->
    throw "Flag type not specified"
  processSubmit: (flag) ->
  processUndo: (flag) ->
  processRunImmediately: (flag) ->
window.SubmitListener = SubmitListener

class VenueSubmitListener extends SubmitListener
  constructor: (@venueresultelement) ->
    @venueresult = @venueresultelement.venueresult
  objectType: () -> "venues"
  processSubmit: (flag) ->
    @venueresult.markFlagged(flag)
  processUndo: (flag) ->
    @venueresult.undoMarkedFlagged(flag)
  processReselect: () ->
    @venueresultelement.toggleSelection()

window.VenueSubmitListener = VenueSubmitListener
