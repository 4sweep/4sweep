class LocationLoadMore
  SEARCH_SIZE = 10

  constructor: (@search, containers, map, results, @tooBig = false) ->
    throw "Indivisible location" unless @search.location.divisible
    @searchableLocations = @divideBounds(@search.location.bounds())
    $(containers.buttons).html(HandlebarsTemplates['explore/load_more_button']())
    @warn = $(containers.warning)
    if @tooBig
      @warn.html(HandlebarsTemplates['explore/too_big_warning']())
    @elems = $(containers.buttons).find('.loadmore')
    @elems.click (e) =>
      e.preventDefault()
      return if $(e.target).hasClass('disabled')
      @perform(map, results)
    if @tooBig
      @elems.text("Search Subareas")

  showSearchSubareas: (map, results) ->
    SEARCH_SIZE = @searchableLocations.length + 1
    nextLocations = @searchableLocations[0..(SEARCH_SIZE-1)]
    @searchableLocations = @searchableLocations[SEARCH_SIZE..]
    prefix = @search.searchPath()
    for o in @search.overlays[1..]
      o.setMap(null)

    overlayExtras =
      strokeColor: "#FFFF00"
      strokeWeight: 2
      fillColor: "#FFFF00"
      map: map

    for location in nextLocations
      @search.addOverlay(overlay) for overlay in location.mapOverlays(overlayExtras)
      @searchableLocations = @searchableLocations.concat(@divideBounds(location.bounds()))

    @elems.removeClass('disabled').text("Load More")

  perform: (map, results) ->
    nextLocations = @searchableLocations[0..(SEARCH_SIZE-1)]
    @searchableLocations = @searchableLocations[SEARCH_SIZE..]
    prefix = @search.searchPath()
    throw "No more locations to search" if nextLocations.length == 0

    # Remove original overlays from map
    # for overlay in @search.location.mapOverlays()
      # overlay.setMap(null)

    overlayExtras =
      strokeColor: "#FFFF00"
      strokeWeight: 2
      fillColor: "#FFFF00"
      map: map

    for location in nextLocations
      @search.addOverlay(overlay) for overlay in location.mapOverlays(overlayExtras)

    searchParams = nextLocations.map (location) =>
      p = $.extend @search.searchParameters(), location.values()
      prefix + "?" + ("#{k}=#{encodeURIComponent(v)}" for own k, v of p when v).join("&")

    @tooBig = false
    @elems.addClass('disabled').text("Loading…")
    $.ajax
      url: "https://api.foursquare.com/v2/multi"
      dataType: "json"
      data:
        requests: searchParams.join ","
        m: "swarm"
        v: API_VERSION
        oauth_token: token
      success: (data) =>
        for response, i in data.response.responses
          @processResponse(map, results, response, nextLocations[i])
        for location in nextLocations
          for overlay in location.mapOverlays()
            overlay.setOptions
              strokeColor: "#B7C9C8"
              strokeWeight: 0.5
              fillColor: "#B7C9C8"
              fillOpacity: 0.2

        results.displayNewResults(map)

        if @hasMore()
          if @tooBig
            @elems.removeClass('disabled').text("Search Subareas")
            @warn.html(HandlebarsTemplates['explore/too_big_warning']())
          else
            @warn.html("")
            @elems.removeClass('disabled').text("Load More")
        else
          @elems.addClass("disabled").text("Loaded All")
          @warn.html("")
      error: () =>
        alert("FIXME: Problem with load more")

  processResponse: (map, results, response, location) =>
    switch
      when response.meta?.code == 200
        venues = @search.parseVenueResults(response)
        for venue in venues
          unless results.has(venue.id)
            vr = new VenueResult(venue, @search.maxId++)
            if (@search.location.containsPoint == undefined) || @search.location.containsPoint(vr.position())
              results.addResult(new VenueResultElement(vr))
        if venues.length > @search.hasMoreLength
          @searchableLocations = @searchableLocations.concat(@divideBounds(location.bounds()))
      when response.meta?.errorType == 'geocode_too_big'
        @searchableLocations = @searchableLocations.concat(@divideBounds(location.bounds()))
        @tooBig = true
      else
        alert("FIXME: other error with this response")

  hasMore: () ->
    return @searchableLocations.length > 0

  divideBounds: (bounds) ->
    result = []

    minLat = bounds.getSouthWest().lat()
    maxLat = bounds.getNorthEast().lat()
    centerLat = (minLat + maxLat) / 2

    minLng = bounds.getSouthWest().lng()
    maxLng = bounds.getNorthEast().lng()
    centerLng = (minLng + maxLng) / 2

    GLatLng = google.maps.LatLng
    result.push new BoundingBoxSearchLocation(new GLatLng(maxLat, centerLng), new GLatLng(centerLat, minLng))
    result.push new BoundingBoxSearchLocation(new GLatLng(maxLat, maxLng), new GLatLng(centerLat, centerLng))
    result.push new BoundingBoxSearchLocation(new GLatLng(centerLat, maxLng), new GLatLng(minLat, centerLng))
    result.push new BoundingBoxSearchLocation(new GLatLng(centerLat, centerLng), new GLatLng(minLat, minLng))

    if @search.location.intersectsRectangle
      result = result.filter (box) => @search.location.intersectsRectangle(box)

    result

  clear: () ->
    @elems.remove()

window.LocationLoadMore = LocationLoadMore
