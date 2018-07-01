class YourFlagsVenueSearch extends VenueSearch
  supportsLoadMore: true

  # Flag search options are:
  #   reporter: true (user reported it) / false (user just voted on it)
  #   resolved: true / false / missing ( = both)
  #   decision: rejected / accepted (missing?)
  #   woeType: info/duplicate/etc (one at a time)
  constructor: (@flagSearchOptions) ->
    super(new GlobalLocation())

  parseVenueResults: (data) ->
    data.response.venues.items

  perform: () ->
    @foursquareVenueAjax "https://api.foursquare.com/v2/users/self/flaggedvenues",
        $.extend @flagSearchOptions,
          limit: 100

window.YourFlagsVenueSearch = YourFlagsVenueSearch
