class ListSearchByUrl extends ListSearch
  searchTab: "listsearch"

  constructor: (@listUrl = "", @location = new GlobalLocation(), @categories = []) ->
    @listUrl = @listUrl.trim()
    super null, @location, @categories

  perform: () ->
    @performListSearchFromUrl(@listUrl)

  # Private methods:

  performListSearchFromUrl: (url) ->
    @clearErrors()

    if result = url.match(/foursquare.com\/user\/([0-9]+)\/list\/([^?\/]+)/i)
      @performListSearchFromUserIdAndList(result[1], result[2], "/user/#{result[1]}/list/#{result[2]}")
    else if result = url.match(/foursquare.com\/(.*)\/list\/([^?\/]+)/i)
      @performListSearchFromUsernameAndList(result[1], result[2])
    else
      @displayError
        errorText: "Cannot recognize list URL. Please check it."

  performListSearchFromUsernameAndList: (username, list) ->
    @clearErrors()

    UserCreatedVenueSearch.lookupByTwitter(username,
      success: (userid) =>
        @performListSearchFromUserIdAndList userid, list, "/#{username}/list/#{list}"
      fail: () =>
        @displayError
          errorText: "Could not find this list.  Please double check the URL"
      error: (xhr, textStatus, errorThrown) =>
        error = @parseError(xhr,textStatus, errorThrown)
        @displayError(error, () => @performListSearchFromUsernameAndList(username, list))
    )

  performListSearchFromUserIdAndList: (userid, list, targetpath, tryoffset = 0) ->
    limit = 200
    @clearErrors()

    $.ajax
      url: "https://api.foursquare.com/v2/users/#{userid}/lists"
      data:
        group: 'created'
        offset: tryoffset
        limit: limit
        v: API_VERSION
        oauth_token: token
        m: 'swarm'
      success: (data) =>
        if (lists = (data.response.lists.items.filter (e) -> e.url.toLowerCase() == targetpath.toLowerCase())).length > 0
          @listId = lists[0].id
          ListSearchByUrl.__super__.perform.call(this) # hacky, but essentially super.perform()
        else if data.response.lists.count > tryoffset+limit
          @performListSearchFromUserIdAndList userid, list, targetpath, tryoffset+limit
        else
          @displayError
            errorText: "Could not find this list.  Please double check the URL"
      error: (xhr, textStatus, errorThrown) =>
        error = @parseError(xhr,textStatus, errorThrown)
        @displayError error, () =>
          @performListSearchFromUserIdAndList(userid, list, targetpath, tryoffset)

  serialize: () ->
    s: @searchTab
    listurl: @listUrl
    cats: @categories.join(',')

  @deserialize: (values) ->
    new ListSearchByUrl(values['listurl'], SearchLocation.deserialize(values), Search.parseCategories(values['cats']))

window.ListSearchByUrl = ListSearchByUrl
