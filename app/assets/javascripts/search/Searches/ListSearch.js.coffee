class ListSearch extends VenueSearch
  supportsLoadMore: false
  searchTab: 'list'

  constructor: (@listId = "", @location = new GlobalLocation(), @categories = []) ->
    super(@location)

  perform: () ->
    limit = 200
    @foursquareVenueAjax("https://api.foursquare.com/v2/lists/#{@listId}",
      limit: limit
      # offset: (@page - 1) * limit
      categoryId: @categories.join(",")
    ,
      asLlBounds: true
    )

  publishExtras: (data) ->
    extras = new ListSearchExtras(data)
    @listeners.notify 'extrasready', extras

  parseVenueResults: (data) ->
    @publishExtras(data.response.list)

    venues = data.response.list.listItems.items.map (e) ->
      if e.venue
        v = e.venue
      else
        v = switch e.type
          when 'venue' then e.venue
          when 'tip' then e.tip.venue
          else throw "Can't find venue for e"
      if v == undefined
        console.log "Possibly deleted venue #{e.id}"
      v

    $.grep venues, (e) -> e

  serialize: () ->
    $.extend @location.serialize,
      s: @searchTab
      cats: @categories.join(",")
      listid: @listId
      # page: @page

  @deserialize: (values) ->
    new ListSearch values['listid'], SearchLocation.deserialize(values), cats.split(',')

window.ListSearch = ListSearch
