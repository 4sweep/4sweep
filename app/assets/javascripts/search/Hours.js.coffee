class Hours
  @parse: (text) ->
    result = fourSq.util.HoursParser.parse(text)
    if result
      new Hours(result.timeframes)
    else
      null

  constructor: (@timeframes = []) ->

  asProposedEdit: () ->
    # The hours for the venue, as a semi-colon separated list of open segments and named segments
    # (e.g., brunch or happy hour). Open segments are formatted as day,start,end. Named segments
    # additionally have a label, formatted as day,start,end,label. Days are formatted as integers
    # with Monday = 1,...,Sunday = 7. Start and End are formatted as [+]HHMM format. Use 24 hour
    # format (no colon), prefix with 0 for HH or MM less than 10. Use '+' prefix, i.e., +0230 to
    # represent 2:30 am past midnight into the following day.
    result = []
    for timeframe in @timeframes
      for day in timeframe.days
        for segment in timeframe.open
          result.push "#{day},#{segment.start},#{segment.end}"

    result.sort().join(";") || ""

  validateForVenue: (venueid, options = {}) ->
    # Attempts to validate the hours against the Foursquare venue.
    # Pass in a success(response) function and it will be called
    # after validation.  response will have a field called 'status',
    # which is known to take on the following values:
    #   'ERROR', 'POPULARHOURSWARNING', 'OK'
    # if the status field is 'POPULARHOURSWARNING' or 'ERROR',
    # a message field with human readable text will be shown.
    #
    # if the status field is 'OK', or 'POPULARHOURSWARNING', an 'hours'
    # field will be included, which is of the same human-optimized
    # format as in a full venue response

    # Let's set up some semi-aggressive caching
    if Hours.cache?[venueid]?[@asProposedEdit()]
      return options.success(Hours.cache[venueid][@asProposedEdit()])

    $.ajax
      dataType: "json"
      url: "https://api.foursquare.com/v2/venues/#{venueid}/validatehours"
      type: "POST"
      success: (data) =>
        Hours.cache = Hours.cache || {}
        Hours.cache[venueid] = Hours.cache[venueid] || {}
        Hours.cache[venueid][@asProposedEdit()] = data.response
        options.success(data.response)
      error: options.error
      data:
        hours: @asProposedEdit()
        m: 'swarm'
        v: API_VERSION
        oauth_token: token

window.Hours = Hours
