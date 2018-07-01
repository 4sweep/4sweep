class RecentlyCreatedVenueSearch extends VenueSearch
  supportsLoadMore: LocationLoadMore
  hasMoreLength: 150
  searchTab: "recentlycreated"

  constructor: (@location, @options = {}) ->
    super(@location)

  perform: () ->
    @foursquareVenueAjax "https://api.foursquare.com/v2#{@searchPath()}", @searchParameters()

  searchPath: () ->
    "/venues/search"

  searchParameters: () ->
    intent: 'recentcreate'
    limit: 200

  serialize: () ->
    $.extend @location.serialize(),
      s: @searchTab

  @deserialize: (values) ->
    new RecentlyCreatedVenueSearch SearchLocation.deserialize values

window.RecentlyCreatedVenueSearch = RecentlyCreatedVenueSearch
