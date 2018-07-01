class UserCreatedVenueSearch extends UserSearch
  pageSize: 200
  supportsLoadMore: false

  constructor: (@user = "", @pagenum = 1, @options = {}) ->
    @usersearchtype = "venuescreated"
    super(@user, @pagenum, @options)

  performFromUserId: (@userid) ->
    if sulevel >= 1
      @foursquareVenueAjax("https://api.foursquare.com/v2" + @searchPath(),
              limit: @pageSize
              offset: (@pagenum-1) * @pageSize
            )
    else
      @displayError
        errorText: "Search Unavailable"
        errorDetails: "This search is only available to Foursquare superusers. " +
                      "Apply at https://foursquare.com/edit/join"

  searchPath: () ->
    "/users/#{@userid}/venues"

  searchParameters: () -> {}

  parseVenueResults: (data) ->
    data.response.venues

  resultsExtras: (data) ->
    pagination: new UnknownSizePagination
      currentPage: @pagenum
      pageSize: @pageSize
      onLastPage: data.response.venues.length < (0.75 * @pageSize)
      searchAtPage: (pagenum) => new UserCreatedVenueSearch(@user, pagenum)
    paginatedLoadMore:
      new PaginatedLoadMore(this,
        initialOffset: 200
        increment: 100
      )

  @deserialize: (values) ->
    new UserCreatedVenueSearch(values['user'], parseInt(values['p']) || 1)

window.UserCreatedVenueSearch = UserCreatedVenueSearch
