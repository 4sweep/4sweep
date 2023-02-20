class Explorer
  constructor: (@elem) ->
    @listeners = new Listeners(['updatedselectedcount', 'submitautomaticallychanged'])

    @zoomedVenue = undefined
    @oldZoom = undefined

    @selected = {}
    @selectedcountText = @elem.find(".selectedcount")

    @filterContainer = new FilterContainer('.filtercontainer')
    @filterContainer.listeners.add "filtersChanged", (filters) => @results?.filterUpdated(filters, @map)
    @setupMap(new google.maps.LatLng(lat, lng))
    @setupSubmitwhen()
    @setupPopoverButtons()
    @setupSearchTabs()
    @setupSorting()
    @sort = JSON.parse(Cookies.get("sort") || '{ "type": "natural", "name": "Natural", "dir": "up", "icon": "alt"}')
    @sortResults() # Just to update icon

    @disableShiftSelection()
    @pinnedResults = new PinnedResults(@elem.find(".pinnedvenues"))

    @setupDynamicSizing()

    @deserializeSearch()
    @setupHashListener()

    fitButtons = new FitButtons(this, @map)

  setupSorting: ->
    @elem.find('.sortresults a.performsort').click (e) =>
      e.preventDefault()
      @sort.type = $(e.target).data('sorttype')
      @sort.icon = $(e.target).data('sorticon')
      @sort.name = $(e.target).data('sortname')
      @sortResults()

    @elem.find(".sortresults .sortdirbutton").click (e) =>
      e.preventDefault()
      @sort.dir = if @sort.dir == "up" then "down" else "up"
      @sortResults()

    @elem.find(".sortrefreshbutton").click (e) =>
      e.preventDefault()
      @sortResults()

  setupDynamicSizing: () ->
    $(window).resize (e) ->
      availableY = $(window).height() - $(".searchcontrols").height() - $(".navbar-fixed-top").height() - $(".footer").height() - 60

      $("#map_canvas").height(availableY)
      $(".allvenues").height(availableY - $(".venuelistcontrols").height() - 5)
    $(window).trigger('resize')

  disableShiftSelection: () ->
    @elem.keydown (e) =>
      keynum = e.keyCode || e.which
      if keynum == 16
        @elem.addClass("unselectable")
    @elem.keyup (e) =>
      keynum = e.keyCode || e.which
      if keynum == 16
        @elem.removeClass("unselectable")

  sortResults: ->
    # save sort prefs
    Cookies.set("sort", JSON.stringify @sort)

    #update sort button
    @elem.find(".sortrefreshbutton").addClass("hide")
    @elem.find(".sortdirbutton i").removeClass().addClass("i-sort-#{@sort.icon}-#{@sort.dir}")
    @elem.find(".activesort").text("Sort: " + @sort.name)

    #do sort
    @results?.sortBy(@sort, @elem.find(".retrieved_venues"))

  setupMap: (initialCenter) ->
    @map = new google.maps.Map document.getElementById("map_canvas"),
      zoom: 15
      center: initialCenter
      mapTypeId: google.maps.MapTypeId.ROADMAP
      mapTypeControl: true
      mapTypeControlOptions:
        style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR
        position: google.maps.ControlPosition.LEFT_BOTTOM

    google.maps.event.addListener @map, 'center_changed', () =>
      @results?.recentered(@map.getCenter())
      @pinnedResults?.recentered(@map.getCenter())
      @elem.find(".sortrefreshbutton").toggleClass("hide", @sort.type != 'distance')
      @zoomedVenue?.setZoomState(false)
      @zoomedVenue = undefined

  setupHashListener: () ->
    $(window).on "hashchange", () =>
      $(".modal").modal('hide')
      @deserializeSearch()
    @filterContainer.listeners.add "filtersChanged", (e) =>
      @saveSearchInHash(@lastSearch)

  setupSearchTabs: () ->
    locationManager = new LocationManager(@map, new CenterRadiusSearchLocation(new google.maps.LatLng(lat, lng), 25000))
    @managers = {}

    tabsIdsToClass =
      'venuesearch': PrimaryVenueSearchTab
      'globalsearch': GlobalSearchTab
      'specificvenuesearch': SpecificVenueSearchTab
      'usersearch': UserSearchTab
      'uncategorizedsearch': UncategorizedVenuesSearchTab
      'listsearch': ListSearchTab
      'recentlycreated': RecentlyCreatedTab
      'pagesearch': PageVenuesSearchTab
      'queuesearch': FlaggedVenuesSearchTab
      'myhistory': MyHistorySearchTab
      'dupsearch': DuplicateSearchTab

    for own id, klass of tabsIdsToClass
      @managers[id] = new klass($("#tab-#{id}"), this, locationManager)
      @managers[id].setupEvents()

    @managers['venuesearch'].shown()

  deserializeSearch: () ->
    window.clearTimeout(@timeoutId) if @timeoutId

    @timeoutId = window.setTimeout( () =>
      hash = (location.href.split("#")[1] || "").replace(/^#/,'') # http://stackoverflow.com/questions/4835784/firefox-automatically-decoding-encoded-parameter-in-url-does-not-happen-in-ie
      if hash == @dontUpdateHash
        # @dontUpdateHash = ""
        return

      if @lastSearch && hash == ""
        return

      hash = hash.replace(/\+/g, "%20")

      obj = {}
      for e in hash.split("&")
        [k,v] = e.split("=")
        obj[k] = decodeURIComponent(v)

      try
        search = Search.deserialize(obj)

        if search.searchTab of @managers
          @managers[search.searchTab].displaySearch(search)
          search.options?.loadMoreContainer = @managers[search.searchTab].tab.find('.loadmorecontainer')
        else
          throw "Unknown search type"
      catch e
        console.log("Problem deserializing search", e) if search?.searchTab
        search = @managers['venuesearch'].createSearch()

      if obj.filter?
        @filterContainer.showFilter(obj.filter)

      search.location.fitMapToLocation(@map)

      @performSearch(search)
    , 500)

  setupPopoverButtons: () ->
    new MakeHomeFlagPopover(this, @elem.find(".mass-home")).attach()
    new MergeFlagPopover(this, @elem.find(".mass-merge")).attach()
    new RemoveFlagPopover(this, @elem.find(".mass-remove")).attach()
    new MakePrivateFlagPopover(this, @elem.find(".mass-private")).attach()
    new RecategorizeFlagPopover(this, @elem.find(".mass-recategorize")).attach()
    new CloseFlagPopover(this, @elem.find(".mass-close")).attach()
    new RefreshAction(this, @elem.find(".mass-refresh")).attach()
    new ExportAction(this, @elem.find(".mass-export")).attach()

  setupSubmitwhen: ->
    $(".submitwhen .submitautomatically").click (e) =>
      e.preventDefault()
      Cookies.set("submitwhen", "automatically")
      @listeners.notify("submitautomaticallychanged", true)
    $(".submitwhen .submitwait").click (e) =>
      e.preventDefault()
      Cookies.set("submitwhen", "wait")
      @listeners.notify("submitautomaticallychanged", false)

    # Initialize to value of cookie
    submitwhen = Cookies.get("submitwhen") || 'automatically'
    $(".submitwhen .submit#{submitwhen}").click()

    $(".submitwhen-help").popover(
      html: true
      title: "Submit automatically vs review"
      placement: "top"
      trigger: "hover"
      content: HandlebarsTemplates['venues/about_autosubmit']()
    )

  updateSelectedCount: () ->
    count = (key for key of @selected).length
    @selectedcountText?.text(count)
    @listeners.notify 'updatedselectedcount', count

  performSearch: (search) ->
    @lastSearch?.searchResults?.clearResults()
    @lastSearch = search

    self = this

    @results = new SearchResults(search, @pinnedResults)
    search.setSearchResults(@results)
    search.setResultsDiv($(".venuediv"))

    @results.listeners.add "newsearchrequested", (newSearch) =>
      @performSearch(newSearch)
      @managers[newSearch.searchTab]?.updateSearch(newSearch)

    search.listeners.add 'resultsready', (search, results) =>
      @results.display($(".venuediv"), @map)

    search.listeners.add 'geotoobig', (search, results) =>
      @results.display($(".venuediv"), @map, {tooBig: true})

    @results.listeners.add 'resultsupdated', (results) =>
      @results.filterUpdated(@filterContainer.filters, @map)
      @sortResults()

    search.listeners.add 'extrasready', (extras) =>
      extras.render($(".venuediv .extrasholder"))

    search.listeners.add 'extrasfailed', () =>
      # FIXME: should we notify users in any way?  It looks ugly as is
      # $(".venuediv .extrasholder").html HandlebarsTemplates['search_extras/extraserror']()

    @results.listeners.add 'clearedresults', (clearedresults) =>
      self.selected = @pinnedResults.selected()
      self.updateSelectedCount()
      self.oldZoom = undefined
      self.zoomedVenue = undefined
      $(".venuediv .extrasholder").html("") # Clear extras

    @results.listeners.add 'resultadded', (results, venue) =>
      venue.listeners.add 'selected', (venue) =>
        self.selected[venue.venueresult.id] = venue
        self.updateSelectedCount()

      venue.listeners.add 'unselected', (venue) =>
        delete self.selected[venue.venueresult.id]
        self.updateSelectedCount()

      venue.listeners.add 'requestzoomin', (position) =>
        return if @zoomedVenue?.venueresult.id == venue.venueresult.id

        @zoomedVenue?.setZoomState(false) # Old zoomed venue

        @oldZoom =
          center: @map.getCenter()
          zoom: @map.getZoom()
        @map.panTo(venue.venueresult.position())
        @map.setZoom(16)
        @zoomedVenue = venue

      venue.listeners.add 'requestzoomout', () =>
        if @oldZoom
          @map.setZoom(@oldZoom.zoom)
          @map.panTo(@oldZoom.center)

        @zoomedVenue = undefined
        @oldZoom = undefined

      venue.listeners.add 'pin', (pinnedResult) =>
        @pinnedResults.addResult(pinnedResult)

    search.perform()
    @saveSearchInHash(search)

  saveSearchInHash: (search) ->
    return unless search
    toSave = $.extend {}, search.serialize(), @filterContainer.serialize()
    hash = ("#{key}=#{encodeURIComponent(val)}" for own key, val of toSave when val).join("&")
    hash = hash.
      replace(/%2C/g, ',').
      replace(/\+/g, '%2B').
      replace(/%20/g, '+').
      replace(/%3B/g,';') #make this a bit more readable
    @dontUpdateHash = hash
    location.hash = hash

window.Explorer = Explorer
