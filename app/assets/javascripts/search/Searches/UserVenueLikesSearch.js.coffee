class UserVenueLikesSearch extends UserSearch
  pageSize: 200  #FIXME: is this right?
  supportsLoadMore: true

  constructor: (@user = "", @pagenum = 1, @options = {}) ->
    @usersearchtype = "venuesliked"
    super(@user, @pagenum, @options)

  searchPath: () ->
    "/users/#{@userid}/venuelikes"

  searchParameters: () -> {}

  parseVenueResults: (data) ->
    data.response.venues.items

  resultsExtras: (data) ->
    pagination: new KnownSizePagination
      totalItems: data.response.venues.count
      currentPage: @pagenum
      pageSize: @pageSize
      searchAtPage: (pagenum) => new UserVenueLikesSearch(@user, pagenum)
    paginatedLoadMore:
      new PaginatedLoadMore(this,
        initialOffset: @pageSize
        increment: 100
      )

  @deserialize: (values) ->
    new UserVenueLikesSearch(values['user'], parseInt(values['p']) || 1)

window.UserVenueLikesSearch = UserVenueLikesSearch
