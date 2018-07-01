class UserSearch extends VenueSearch
  searchTab: 'usersearch'

  @userDetailsCache = {}

  @twitterUserIdCache = {}

  constructor: (@user = "", @pagenum = 1, @options = {}) ->
    switch
      when result = @user.match(/https?:\/\/.*foursquare\.com\/us?e?r?\/([0-9]+)/i)
        @user = result[1]
      when result = @user.match(/https?:\/\/.*foursquare\.com\/([^\/]+)/i)
        @user = result[1]

    super(new GlobalLocation())

  perform: () ->
    if @user.trim().length == 0
      @displayError
        errorText: "Please provide a user ID or Twitter name."
      return
    else if @user.match(/^[0-9]+$/) or @user == 'self'
      @performFromUserId(@user)
      @performExtrasSearch(@user)
    else
      UserCreatedVenueSearch.lookupByTwitter(@user,
        success: (userid) =>
          @performFromUserId(userid)
          @performExtrasSearch(userid)
        fail: () =>
          @displayError
            errorText: "Could not find a user with this ID or Twitter name."
        error: (xhr, textStatus, errorThrown) =>
          error = @parseError(xhr,textStatus, errorThrown)
          @displayError(error, () => @perform())
      )

  performFromUserId: (@userid) ->
    @foursquareVenueAjax("https://api.foursquare.com/v2" + @searchPath(),
        limit: @pageSize
        offset: (@pagenum-1) * @pageSize
    )

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

  performExtrasSearch: (userid) ->
    UserExtras.getOrCreate(userid,
      success: (userExtras) =>
        @listeners.notify "extrasready", userExtras
    )

  serialize: () ->
    s: @usersearchtype
    user: @user
    p: @pagenum if @pagenum > 1

  @lookupByTwitter: (twitterName, options) ->
    if UserCreatedVenueSearch.twitterUserIdCache[twitterName]
      options.success(UserCreatedVenueSearch.twitterUserIdCache[twitterName])
    else
      $.ajax
        url: "https://api.foursquare.com/v2/users/search"
        data:
          twitter: twitterName
          v: API_VERSION
          oauth_token: token
          m: 'swarm'
        success: (response) ->
          userid = response.response.results?[0]?.id
          if userid
            UserCreatedVenueSearch.twitterUserIdCache[twitterName] = userid
            options.success(userid)
          else
            options.fail()
        error: options.error

  @deserialize: (values) ->
    new UserCreatedVenueSearch(values['user'], parseInt(values['p']) || 1)

window.UserSearch = UserSearch
