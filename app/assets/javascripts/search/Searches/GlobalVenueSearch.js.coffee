class GlobalVenueSearch extends VenueSearch
  supportsLoadMore: false
  searchTab: 'globalsearch'

  constructor: (@query = "", @categories = []) ->
    super(new GlobalLocation())

  perform: () ->
    if @query.trim().length == 0
      @displayError
        errorText: "Please specify some search keywords."
      return
    @foursquareVenueAjax("https://api.foursquare.com/v2/venues/search",
      limit: 250
      intent: "global"
      query: @query
      categoryId: @categories.join(",")
    )

  serialize: () ->
    s: @searchTab
    q: @query
    cats: @categories.join(",")

  @deserialize: (values) ->
    new GlobalVenueSearch(values['q'], Search.parseCategories(values['cats']))

window.GlobalVenueSearch = GlobalVenueSearch
