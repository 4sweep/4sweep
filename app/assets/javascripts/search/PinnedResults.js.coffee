class PinnedResults
  constructor: (@elem) ->
    @pinned = {}

  addResult: (venueelement) ->
    @pinned[venueelement.venueresult.id] = venueelement
    rendered = venueelement.render()
    rendered.on "click", ".clear_venue", (e) =>
      e.preventDefault()
      @unPin(venueelement)
    @elem.append(rendered)

    venueelement.listeners.add "unpin", (e) =>
      @unPin(venueelement)

    # TODO: add listener to close on scroll, etc?  Review SearchResults's approach
    @showHideSeparator()

  unPin: (venueelement) ->
    delete @pinned[venueelement.venueresult.id]
    venueelement.remove()
    @showHideSeparator()

  selected: () ->
    result = {}
    for own id, venueresult of @pinned when venueresult.status.clicked
      result[id] = venueresult
    result

  recentered: (newCenter) ->
    for id, venueresult of @pinned
      venueresult.updateDistance(newCenter)

  showHideSeparator: () ->
    @elem.toggleClass("haspins", (id for own id of @pinned).length > 0)

  get: (venueid) ->
    # returns the pinned venue with this id, or undefined if none exists
    @pinned[venueid]

  pinnedBounds: () ->
    bounds = new google.maps.LatLngBounds()
    for own id, venueelement of @pinned
      bounds.extend(venueelement.venueresult.position())
    bounds

window.PinnedResults = PinnedResults
