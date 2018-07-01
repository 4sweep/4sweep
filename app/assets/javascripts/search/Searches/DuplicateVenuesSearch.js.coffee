class DuplicateVenuesSearch extends VenueSearch
  searchTab: 'dupsearch'
  supportsLoadMore: LocationLoadMore
  hasMoreLength: 30

  constructor: (@locationsString = "", @pagenum = 1, @query = "", @radius = 1000, overrideLocation) ->
    @pagenum = parseInt(@pagenum) || 1
    @locations = @locationsString.split(";")
    @radius = parseInt(@radius) || 1000
    @location = switch
      when overrideLocation then overrideLocation
      when @locations[@pagenum - 1]
        CenterRadiusSearchLocation.deserialize
          ll: @locations[@pagenum - 1] || "0,0"
          radius: @radius
      else
        undefined

    super(@location)

  searchPath: () ->
    "/venues/search"

  searchParameters: () ->
    query: @query
    intent: "browse"
    limit: 50

  resultsExtras: () ->
    pagination:
      new UnknownSizePagination
        totalItems: @locations.length
        currentPage: @pagenum
        pageSize: 1
        onLastPage: @pagenum == @locations.length
        searchAtPage: (pagenum) => new DuplicateVenuesSearch(@locations.join(';'), pagenum, @query, @radius)

  perform: () ->
    unless @location
      @displayError
        errorText: "Please specify a list of search locations. You can select venues from another search and export them here."
      return
    @foursquareVenueAjax "https://api.foursquare.com/v2/#{@searchPath()}", @searchParameters()

  parseVenueResults: (data) ->
    data.response.venues

  serialize: () ->
    s: @searchTab
    q: @query
    locations: @locationsString
    radius: @radius
    p: @pagenum

  @deserialize: (values) ->
    new DuplicateVenuesSearch values['locations'], values['p'], values['q'], values['radius']

  # Throws error with error.name = "SyntaxError" if the location list cannot be parsed
  @locationsFromString: (text) ->
    # Using the pegjs js for advancedsearch just to save the complication of two parsers
    locations = advancedsearch.parse(text, {startRule: 'locationlist'})


window.DuplicateVenuesSearch = DuplicateVenuesSearch
