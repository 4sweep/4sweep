class MyCheckinHistorySearch extends VenueSearch
  pageSize: 200
  searchTab: 'myhistory'

  constructor: (@categories = [], @start, @end, @pagenum = 1, @options = {}) ->
    super(new GlobalLocation())

  perform: () ->
    @foursquareVenueAjax "https://api.foursquare.com/v2#{@searchPath()}", @searchParameters()

  searchPath: () ->
    "/users/self/venuehistory"

  searchParameters: () ->
    limit: @pageSize
    offset: (@pagenum-1)*@pageSize
    m: 'swarm'
    categoryId: @categories.join(',')
    beforeTimestamp: @parseTime(@end)
    afterTimestamp: @parseTime(@start)

  parseTime: (timestring) ->
    if moment(timestring, "YYYY-MM-DD").isValid()
      moment(timestring, "YYYY-MM-DD").format("X") #To UNIX timestamp
    else
      undefined

  resultsExtras: (data) ->
    pagination: new KnownSizePagination
      totalItems: data.response.venues.count
      currentPage: @pagenum
      pageSize: @pageSize
      searchAtPage: (pagenum) => new MyCheckinHistorySearch(@categories, @start, @end, pagenum)

    paginatedLoadMore:
      new PaginatedLoadMore(this,
        totalItems: data.response.venues.count
        increment: @pageSize
        initialOffset: @pageSize
      )

  parseVenueResults: (data) ->
    data.response.venues.items.map (e) -> e.venue

  serialize: () ->
    s: @searchTab
    p: @pagenum if @pagenum > 1
    cats: @categories.join(',')
    start: @start
    end: @end

  @deserialize: (values) ->
    new MyCheckinHistorySearch(Search.parseCategories(values['cats']),
      values['start'],
      values['end'],
      parseInt(values['p']) || 1)

window.MyCheckinHistorySearch = MyCheckinHistorySearch
