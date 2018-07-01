class PageVenuesSearch extends VenueSearch
  pageSize: 100
  @extrasCache = {}
  searchTab: 'pagesearch'

  constructor: (@pageid = "", @location = new GlobalLocation(), @pagenum = 1, @options = {}) ->
    @pageid = @pageid.toString().trim()
    @pagesearchtype = 'id'
    super(@location)

  perform: () ->
    if @pageid == ""
      @displayError
        errorText: "Please provide a valid page ID"
      return

    @foursquareVenueAjax "https://api.foursquare.com/v2#{@searchPath()}", @searchParameters()

    @performExtrasSearch()

  searchPath: () ->
    "/pages/#{@pageid}/venues"

  searchParameters: () ->
    limit: @pageSize
    offset: (@pagenum-1) * @pageSize

  performExtrasSearch: () ->
    UserExtras.getOrCreate(@pageid,
      success: (userExtras) =>
        @listeners.notify "extrasready", userExtras
      error: (xhr, textStatus, errorThrown) =>
        @listeners.notify "extrasfailed"
    )

  parseVenueResults: (data) ->
    data.response.venues.items

  resultsExtras: (data) ->
    pagination:
      if @location instanceof GlobalLocation
        new KnownSizePagination
          totalItems: data.response.venues.count
          currentPage: @pagenum
          pageSize: @pageSize
          searchAtPage: (pagenum) => new PageVenuesSearch(@pageid, @location, pagenum)
      else
        new UnknownSizePagination
          currentPage: @pagenum
          pageSize: @pageSize
          onLastPage: data.response.venues.items.length < (0.75 * @pageSize)
          searchAtPage: (pagenum) => new PageVenuesSearch(@pageid, @location, pagenum)

    paginatedLoadMore:
      new PaginatedLoadMore(this,
        totalItems: data.response.venues.count
      )

  serialize: () ->
    $.extend @location.serialize(),
      s: @searchTab
      pageid: @pageid
      p: @pagenum if @pagenum > 1

  @deserialize: (values) ->
    new PageVenuesSearch(values['pageid'], SearchLocation.deserialize(values), parseInt(values['p']) || 1)

window.PageVenuesSearch = PageVenuesSearch
