class UserPhotoVenueSearch extends UserSearch
  pageSize: 500
  supportsLoadMore: true

  constructor: (@user = "", @pagenum = 1, @options = {}) ->
    @usersearchtype = "venuesphotoed"
    super(@user, @pagenum, @options)

  searchPath: () ->
    "/users/#{@userid}/photos"

  searchParameters: () -> {}

  parseVenueResults: (data) ->
    data.response.photos.items.filter( (p) -> p.venue).map (p) -> p.venue # Deduplication handled by search results

  resultsExtras: (data) ->
    pagination: new KnownSizePagination
      totalItems: data.response.photos.count
      currentPage: @pagenum
      pageSize: @pageSize
      searchAtPage: (pagenum) => new UserPhotoVenueSearch(@user, pagenum)
    paginatedLoadMore:
      new PaginatedLoadMore(this,
        initialOffset: @pageSize
        increment: 100
      )

  @deserialize: (values) ->
    new UserPhotoVenueSearch(values['user'], parseInt(values['p']) || 1)

window.UserPhotoVenueSearch = UserPhotoVenueSearch
