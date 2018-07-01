class UserTipVenueSearch extends UserSearch
  pageSize: 200
  supportsLoadMore: true

  constructor: (@user = "", @pagenum = 1, @options = {}) ->
    @usersearchtype = "venuestipped"
    super(@user, @pagenum, @options)

  searchPath: () ->
    "/lists/#{@userid}/tips"

  searchParameters: () -> {}

  parseVenueResults: (data) ->
    data.response.list.listItems.items.filter( (t) -> t.venue).map (t) -> t.venue

  resultsExtras: (data) ->
    pagination: new KnownSizePagination
      totalItems: data.response.list.listItems.count
      currentPage: @pagenum
      pageSize: @pageSize
      searchAtPage: (pagenum) => new UserTipVenueSearch(@user, pagenum)
    paginatedLoadMore:
      new PaginatedLoadMore(this,
        initialOffset: @pageSize
        increment: 100
      )

  @deserialize: (values) ->
    new UserTipVenueSearch(values['user'], parseInt(values['p']) || 1)

window.UserTipVenueSearch = UserTipVenueSearch
