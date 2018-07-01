class SpecificVenueSearch extends VenueSearch
  supportsLoadMore: false
  suppressFilters: true
  searchTab: 'specificvenuesearch'

  constructor: (@venueid = "") ->
    @specificvenuetype = "specificvenue"
    super(new GlobalLocation())

  perform: () ->
    if @venueid.trim().match(/^[0-9a-f]{24}$/)
      @foursquareVenueAjax("https://api.foursquare.com/v2/venues/#{@venueid.trim()}")
    else
      @displayError
        errorText: "Please enter a valid Foursquare venue ID"

  parseVenueResults: (data) ->
    [data.response.venue]

  serialize: () ->
    s: @searchTab
    venueid: @venueid

  @deserialize: (values) ->
    new SpecificVenueSearch(values['venueid'])

window.SpecificVenueSearch = SpecificVenueSearch
