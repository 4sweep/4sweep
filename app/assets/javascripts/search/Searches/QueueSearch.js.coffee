class QueueSearch extends VenueSearch
  supportsLoadMore: false
  searchTab: 'queuesearch'
  pageSize: 50

  constructor: (@queueType, @location = new GlobalLocation()) ->
    super(@location)

  perform: () ->
    @loadMore()

  parseVenueResults: (data) ->
    data.response.venues.items

  resultsExtras: (data) ->
    paginatedLoadMore:
      new PaginatedLoadMore(this, {})

  searchParameters: () ->
    type: @queueType
    limit: @pageSize

  searchPath: () ->
    "/venues/flagged"

  loadMore: () ->
    @foursquareVenueAjax "https://api.foursquare.com/v2#{@searchPath()}", @searchParameters()

  serialize: () ->
    $.extend @location.serialize(),
      s: @searchTab
      queue: @queueType

  @deserialize: (values) ->
    new QueueSearch values['queue'], SearchLocation.deserialize(values)

window.QueueSearch = QueueSearch
