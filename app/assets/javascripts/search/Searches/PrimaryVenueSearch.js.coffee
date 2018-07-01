class PrimaryVenueSearch extends VenueSearch
  supportsLoadMore: LocationLoadMore
  hasMoreLength: 30
  searchTab: 'venuesearch'

  constructor: (@query = "", @location, @categories = [], @options = {}) ->
    super(@location)

  perform: () ->
    @foursquareVenueAjax "https://api.foursquare.com/v2#{@searchPath()}", @searchParameters()

  searchPath: () ->
    "/venues/search"

  searchParameters: () ->
    query: @query
    categoryId: @categories.join(",")
    intent: "browse"
    limit: 50

  parseVenueResults: (data) ->
    data.response.venues

  serialize: () ->
    $.extend @location.serialize(),
      s: @searchTab
      q: @query
      cats: @categories.join(',')

  @deserialize: (values) ->
    new PrimaryVenueSearch values['q'],
      SearchLocation.deserialize(values),
      Search.parseCategories(values['cats'])

window.PrimaryVenueSearch = PrimaryVenueSearch
