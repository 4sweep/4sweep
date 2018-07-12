class Search
  constructor: (@location, @searchresults) ->
    @maxId = 1
    @listeners = new Listeners(['resultsready', 'searchfailed', 'extrasready', 'geotoobig', 'searchgeocoded', 'extrasfailed'])
    @overlays = @location?.mapOverlays().slice() || []

  setSearchResults: (@searchResults) -> this

  setResultsDiv: (@resultsDiv) -> this

  addOverlay: (overlay) ->
    @overlays.push overlay

  clearErrors: () ->
    @resultsDiv?.find(".loading").removeClass('hide')
    @resultsDiv?.find(".errorcontainer").html ""
    @resultsDiv?.find(".noresults").remove()
    @resultsDiv?.find(".searcherror").remove()

  foursquareVenueAjax: (url, params, locationOptions) ->
    @clearErrors()

    $.ajax
      url: url
      dataType: "json"
      data:
        $.extend({v: API_VERSION, oauth_token: token, m: "swarm"}, @location.values(locationOptions), params)
      success: (data) =>
        if data.response.geocode
          @setSearchLocation(data.response.geocode)
          @listeners.notify "searchgeocoded", data.response.geocode
        @processVenueResponse(data)
      error: (xhr, textStatus, errorThrown) =>
        if xhr.responseJSON?.meta?.errorType == 'geocode_too_big' && @location.divisible
          @geoTooBig()
        else
          error = @parseError(xhr,textStatus, errorThrown)
          @displayError(error, () => @foursquareVenueAjax(url, params, locationOptions))

  parseError: (xhr, textStatus, errorThrown) ->
    if (xhr?.responseJSON?.meta?.errorDetail)
      errorDetails = xhr?.responseJSON?.meta?.errorDetail
      errorText = "Foursquare API Error"
    else
      errorText = switch
        when xhr.status == 0 then "Foursquare server error or network connection failure.";
        when xhr.status >= 500 and xhr.status then "A server error occurred, please try again later."
        when textStatus == 'timeout' then "The request timed out. Please try again."
        else
          # Rollbar.error("AJAX error: ", {xhr: xhr, textStatus: textStatus, errorThrown: errorThrown})
          "An unknown error occurred. Try again, and if the problem continues, please email foursweep@foursquare.com"

    return {
      errorDetails: errorDetails
      errorText: errorText
    }

  displayError: (error, retryFunction) ->
    @listeners.notify "searchfailed", this
    @resultsDiv?.find(".loading").addClass("hide")
    error.retryable = retryFunction != undefined
    errorDiv = $ HandlebarsTemplates['explore/venue_load_error'](error)

    errorDiv.find(".retry").click (e) =>
      e.preventDefault()
      retryFunction()

    @resultsDiv?.find(".errorcontainer").html errorDiv

  geoTooBig: () ->
    @listeners.notify "geotoobig", this, @result

  processVenueResponse: (data) ->
    @searchResults = @resultsFromVenues(@parseVenueResults(data), @resultsExtras(data))
    @listeners.notify "resultsready", this, @result

  resultsFromVenues: (venues, extras) ->
    for venue in venues
      vr = new VenueResult(venue, @maxId++)
      if (@location.containsPoint == undefined) || @location.containsPoint(vr.position())
        @searchResults.addResult(new VenueResultElement(vr))
    @searchResults.setExtras extras if extras
    @searchResults

  resultsExtras: (data) -> {}

  displayOverlaysOnMap: (map) ->
    for overlay in @overlays
      overlay.setMap(map)

    # This methods should be renamed. Its used for non-overlay
    # map indicators, such as global and near
    @location.activateMapOverlay() if map

  setSearchLocation: (geocode) ->
    @location = new BoundingBoxSearchLocation(
      new google.maps.LatLng(geocode.feature.geometry.bounds.ne.lat, geocode.feature.geometry.bounds.ne.lng),
      new google.maps.LatLng(geocode.feature.geometry.bounds.sw.lat, geocode.feature.geometry.bounds.sw.lng)
    )

  perform: () ->
    []

  clear: () ->
    @displayOverlaysOnMap null
    @overlays = null

  serialize: () ->
    throw "Don't know how to serialize this"

  @deserialize: (values) ->
    type = switch values['s']
      when 'globalsearch' then GlobalVenueSearch
      when 'listsearch' then ListSearchByUrl
      when 'venuesearch' then PrimaryVenueSearch
      when 'recentlycreated' then RecentlyCreatedVenueSearch
      when 'specificvenuesearch' then SpecificVenueSearch
      when 'uncategorizedsearch' then UncategorizedQueueSearch
      when 'usersearch' then UserCreatedVenueSearch # For backward compatibility
      when 'usercreated' then UserCreatedVenueSearch
      when 'venuesliked' then UserVenueLikesSearch
      when 'venuesphotoed' then UserPhotoVenueSearch
      when 'venuestipped' then UserTipVenueSearch
      when 'myhistory' then MyCheckinHistorySearch
      when 'pagesearch' then PageVenuesSearch
      when 'queuesearch' then QueueSearch
      when 'dupsearch' then DuplicateVenuesSearch
      when 'childrensearch' then VenueChildrenSearch
      else throw "Don't know how to deserialize #{values['s']}"

    type.deserialize(values)

  @parseCategories: (string) ->
    (string?.split(',').filter (e) -> e && e.match(/[0-9a-f]{24}/)) || []
window.Search = Search
