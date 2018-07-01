class VenueChildrenSearch extends VenueSearch
  supportsLoadMore: false
  searchTab: 'specificvenuesearch'

  constructor: (@venueid = "") ->
    @specificvenuetype = "venuechildren"
    super(new GlobalLocation())

  perform: () ->
    if @venueid.trim().match(/^[0-9a-f]{24}$/)
      @foursquareVenueAjax("https://api.foursquare.com/v2/venues/#{@venueid.trim()}/children")
    else
      @displayError
        errorText: "Please enter a valid Foursquare venue ID"

  parseVenueResults: (data) ->
    data.response.children.groups.map((e) -> e.items).reduce((a, b) -> a.concat(b))

  serialize: () ->
    s: 'childrensearch'
    venueid: @venueid

  @deserialize: (values) ->
    new VenueChildrenSearch(values['venueid'])

window.VenueChildrenSearch = VenueChildrenSearch
