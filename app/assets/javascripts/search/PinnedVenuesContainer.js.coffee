class PinnedVenuesContainer
  constructor: (@container) ->
  add: (venueResultElement) ->
    @container.append(venueResultElement.pinnedElement())
window.PinnedVenuesContainer = PinnedVenuesContainer
