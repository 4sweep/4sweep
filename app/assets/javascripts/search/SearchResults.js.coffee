class SearchResults
  TOGGLEABLE_FIELDS = [
    {field: 'home', name: "home(s)", default: false},
    {field: 'private', name: "private place(s)", default: false},
    {field: 'closed', name: "closed place(s)", default: true},
    {field: 'deleted', name: "deleted place(s)", default: true},
    {field: 'alreadyflagged', named: "already flagged place(s)", default: true}
  ]

  constructor: (@search, @pinned) ->
    @results = {}
    @displayedResults = {}
    @lastClicked = undefined
    @listeners = new Listeners(['clearedresults', 'resultadded', 'newsearchrequested', 'resultsupdated'])
    @toggles = {}
    for field in TOGGLEABLE_FIELDS
      @toggles[field.field] = if $.cookie("show#{field.field}") == undefined then field.default else ($.cookie("show#{field.field}") == "true")

  addResult: (venue) ->
    if @results[venue.venueresult.id]
      return # noop, venue is already known

    if pinnedVenue = @pinned.get(venue.venueresult.id)
      order = venue.venueresult.order
      venue = pinnedVenue.createPinnedVersion()
      venue.venueresult.order = order
      venue.venueresult.refreshEverything(true)

    venue.venueresult.listeners.add "markedflagged", (e) => @showStats()
    venue.venueresult.listeners.add "unmarkedflagged", (e) => @showStats()

    if sulevel >= 2
      venue.listeners.add "multiselectionrequested", (endVenue) =>
        @selectRange(endVenue) if @lastClicked

    venue.listeners.add "clicked", (venue) =>
      @lastClicked = venue

    @results[venue.venueresult.id] = venue
    @listeners.notify "resultadded", this, venue
    this

  has: (id) ->
    id of @results

  selectRange: (endVenue) ->
    [start, end] = [@lastClicked.elem.index(), endVenue.elem.index()].sort( (a,b) -> a-b )
    for e in @resultslist.children("li.venue")[start..end]
      vre = @results[$(e).data('venueid')]
      vre.toggleSelection(endVenue.status.clicked) unless vre.isHidden()

  setExtras: (@extras) -> this

  sortBy: (sort, targetdiv) ->
    venues = for own id, venue of @results
      venue

    v.elem.detach() for v in venues
    sorted = venues.sort (a, b) ->
      a.compareTo(b, sort.type) * if sort.dir == 'down' then -1 else 1
    targetdiv.append(v.elem) for v in sorted

    # On sort, clear out last selected
    @lastClicked = undefined

  filterUpdated: (filters, map) ->
    unless @search.suppressFilters
      for own key, venueresultelement of @results
        venueresultelement.applyFilters(filters, @toggles, map)
      @showStats()

  # Display the result on a map / list, initially
  display: (resultsdiv, map, options = {}) ->
    resultsdiv.find(".loading").addClass('hide')
    resultsdiv.find(".noresults").remove()
    @search.displayOverlaysOnMap(map)
    @resultslist = resultsdiv.find(".retrieved_venues")
    @statsRow = resultsdiv.find(".searchstats")
    self = this

    @displayNewResults(map)

    if (id for own id, keys of @results).length == 0
      @resultslist.append(HandlebarsTemplates['explore/no_venues_found']()) unless options.tooBig

    if (@search.location.renderable())
      @search.location.fitMapToLocation(map)
    else
      @fitMapToResults(map)

    $(resultsdiv).find(".allvenues").off("scroll").on "scroll", () =>
      @resultslist.find('.open-popover').popover('hide')

    @statsRow.off("click").on "click", ".hideshow", (e) ->
      e.preventDefault()
      self.toggleShownStatus(map, this)

    @resultslist.on "click", ".clear_venue", (e) =>
      @removeResult($(e.target).data('venueid'))

    @paginationholder = resultsdiv.find(".paginationholder")
    if @extras?.pagination
      @paginationholder.append(@extras.pagination.render((search) => @listeners.notify("newsearchrequested", search)))

    loadMoreContainers =
      buttons: resultsdiv.find(".loadmorecontainer").add(@search.options?.loadMoreContainer)
      warning: resultsdiv.find(".loadmorewarning")
      pagination: @paginationholder

    if @search.location.divisible && @search.supportsLoadMore
      @loadMore = new LocationLoadMore(@search, loadMoreContainers, map, this, options.tooBig == true)

    if @extras?.paginatedLoadMore
      @loadMore = @extras?.paginatedLoadMore
      @loadMore.attachToElements(loadMoreContainers, map, this)

  displayNewResults: (map) ->
    self = this
    allvenues = @resultslist.parents(".allvenues")

    for id, venueresult of @results when !(id of @displayedResults)
      do (id, venueresult) ->
        self.resultslist.append(venueresult.render())
        venueresult.showMarker(map)
        venueresult.toggleVisibilityByStatuses(map, self.toggles) unless self.search.suppressFilters

        google.maps.event.addListener venueresult.marker, 'click', () ->
          # When you click on a venue marker, scroll to it in this result
          scrollTo = allvenues.scrollTop() + venueresult.elem.position().top - allvenues.position().top
          allvenues.scrollTop(scrollTo)

        self.displayedResults[id] = true

    @fetchAlreadyFlagged(map)
    @showStats()
    @listeners.notify 'resultsupdated', this

  toggleShownStatus: (map, elem) ->
    unless @search.suppressFilters
      item = $(elem).data('status')
      @toggles[item] = !@toggles[item]
      $.cookie("show#{item}", @toggles[item])
      for id, venueresult of @results
        venueresult.toggleVisibilityByStatuses(map, @toggles)
      @showStats()

  showStats: () ->
    unless @search.suppressFilters
      stats = @calculateStats()

      @statsRow?.html(HandlebarsTemplates['explore/searchstats']
        stats: @calculateStats()
        toggles: @toggles
        fields: TOGGLEABLE_FIELDS
        suppressplaces: stats.home > 0 or stats.private > 0 or stats.deleted > 0 or stats.closed > 0 or stats.filtered > 0 or stats.alreadyflagged > 0
      .replace(/(\r\n|\n|\r)/gm, '')
      )

      @resultslist?.find(".allresultsfiltered").remove()
      if stats.displayed == 0 and (id for own id of @results).length > 0
        @resultslist.append(HandlebarsTemplates['explore/allresultsfiltered'](stats))

  calculateStats: () ->
    @stats =
      home: 0
      private: 0
      filtered: 0
      closed: 0
      deleted: 0
      displayed: 0
      alreadyflagged: 0
      total: 0

    for id, venueelement of @results
      @stats.total++
      for item in ['home', 'private', 'closed', 'deleted', 'alreadyflagged', 'filtered']
        @stats[item]++ if venueelement.status[item] or venueelement.venueresult.venuedata?[item] or venueelement.venueresult.status?[item]
      @stats['displayed']++ unless venueelement.status.hidden

    @stats

  recentered: (newCenter) ->
    for id, venueresult of @results
      venueresult.updateDistance(newCenter)

  fetchAlreadyFlagged: (map) ->
    FlagSubmissionService.get().getAlreadyFlaggedStatuses (id for own id of @results),
      type: 'venue'
      success: (flags) =>
        for flag in (flags || [])
          for venueelement in [@results[flag.venueId], @results[flag.secondaryVenueId]] when venueelement
            venueelement.venueresult.markFlagged(flag)
        for id, venueresult of @results
          venueresult.toggleVisibilityByStatuses(map, @toggles) unless @search.suppressFilters
        @showStats()
      error: () =>
        # FIXME: What to do here? Report to rollbar? Retry logic? Ignore?

  removeResult: (venueid) ->
    venueresult = @results[venueid]?.remove()
    delete @results[venueid]
    @showStats()

  clearResults: () ->
    @resultslist?.find(".open-popover").popover('hide')
    @removeResult(id) for own id, venueresult of @results

    @search.clear()
    @statsRow?.html ""
    @paginationholder?.html ""
    @results = {}
    @loadMore?.clear()

    @listeners.notify 'clearedresults', this

  resultsBounds: () ->
    bounds = new google.maps.LatLngBounds()
    for own id, venueelement of @results when venueelement.status.filtered == false
      bounds.extend(venueelement.venueresult.position())
    bounds

  fitMapToResults: (map) ->
    # FIXME: how to deal with @results size of 0, 1
    bounds = new google.maps.LatLngBounds()
    for id, venueelement of @results when venueelement.status.hidden isnt true
      bounds.extend(venueelement.venueresult.position())

    map.fitBounds(bounds) unless bounds.isEmpty()

window.SearchResults = SearchResults
