class VenueSearch extends Search
  constructor: (@location) ->
    super(@location)

  # A default method for venue search results, some might override this
  parseVenueResults: (data) ->
    data.response.venues

window.VenueSearch = VenueSearch
