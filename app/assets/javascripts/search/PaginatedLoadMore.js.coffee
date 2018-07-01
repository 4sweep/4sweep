# PaginatedLoadMore allows perform() to load the next set of venues
# from a result list that contains a known item count and allows
# limit and offset parameters.
class PaginatedLoadMore
  constructor: (@search, options) ->
    @pageSize = options.pageSize || @search.pageSize
    @totalItems = options.totalItems
    @increment = options.increment || @pageSize
    @currentOffset = options.initialOffset || 0

  attachToElements: (containers, map, results) ->
    $(containers.buttons).html(HandlebarsTemplates['explore/load_more_button']())
    @elems = $(containers.buttons).find('.loadmore')
    @elems.click (e) =>
      e.preventDefault()
      return if $(e.target).hasClass('disabled')
      @perform(map, results)
      containers.pagination.html ""

  perform: (map, results) ->
    @elems.addClass('disabled').removeClass('btn-warning').addClass('btn-info').text("Loading…")

    # Could do this via multi instead?
    $.ajax
      url: "https://api.foursquare.com/v2#{@search.searchPath()}"
      dataType: "json"
      data: $.extend @search.searchParameters(), (@search.location?.values() || {}),
        limit: @pageSize
        offset: @currentOffset
        m: "swarm"
        v: API_VERSION
        oauth_token: token
      success: (data) =>
        venues = @search.parseVenueResults(data)
        @lastReturnedCount = venues.length
        for venue in venues when !results.has(venue.id)
          vr = new VenueResult(venue, @search.maxId++)
          if (@search.location.containsPoint == undefined) || @search.location.containsPoint(vr.position())
            results.addResult(new VenueResultElement(vr))

        results.displayNewResults(map)

        @currentOffset += @increment

        if @hasMore()
          @elems.removeClass('disabled').text("Load More")
        else
          @elems.addClass("disabled").text("Loaded All")

      error: () =>
        @elems.addClass('btn-warning').removeClass('btn-info').removeClass("disabled").text("Try Again")

  hasMore: () ->
    if @totalItems
      @currentOffset < @totalItems
    else
      @lastReturnedCount > 0

  clear: () ->
    @elems.remove()


window.PaginatedLoadMore = PaginatedLoadMore
