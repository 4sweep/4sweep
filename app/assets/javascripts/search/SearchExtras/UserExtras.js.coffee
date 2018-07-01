class UserExtras extends SearchExtras
  @userExtrasCache = {}

  @getOrCreate: (userid, options) ->
    if (userid || "").trim() == ""
      return options.error?()

    if @userExtrasCache[userid]
      options.success @userExtrasCache[userid]
    else
      requests = [
        {key: "user", url: "/users/#{userid}"},
        # {key: "followers", url: "/users/#{userid}/followers?limit=1"},
        # {key: "following", url: "/users/#{userid}/following?limit=1"},
        {key: "venuelikes", url: "/users/#{userid}/venuelikes?limit=1"},
        {key: "lists", url: "/users/#{userid}/lists?limit=1"}
      ]
      $.ajax
        url: "https://api.foursquare.com/v2/multi"
        dataType: 'json'
        data:
          requests: (k.url for k in requests).join(",")
          v: API_VERSION
          oauth_token: token
          m: "swarm"
        success: (data) =>
          userDetails = {}
          for req, i in requests
            if data.response.responses[i].meta.code == 200
              userDetails[req.key] = data.response.responses[i].response
          unless userDetails.user
            return options.error() if options.error
          extras = new UserExtras(userDetails)
          UserExtras.userExtrasCache[userid] = extras
          options.success(extras)
        error: (xhr, textStatus, errorThrown) =>
          options.error(xhr, textStatus, errorThrown) if options.error

  constructor: (@userDetails) ->
    @user = @userDetails.user.user
    @id = @user.id

  listCounts: () ->
    counts = {created: 0, followed: 0}
    for listcount in @userDetails.lists.lists.groups
      counts[listcount.type] = listcount.count
    counts

  render: (extrasDiv) ->
    elem = $ HandlebarsTemplates['search_extras/userextras']($.extend @user, @userDetails, {listCounts: @listCounts()}, interactive: true)
    elem.find(".edittips").click (e) =>
      e.preventDefault()
      new UserTipModal(this).show()
    elem.find(".editphotos").click (e) =>
      e.preventDefault()
      new UserPhotoModal(this).show()

    extrasDiv.html(elem)

window.UserExtras = UserExtras
