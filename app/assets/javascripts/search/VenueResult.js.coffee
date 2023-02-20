class VenueResult
  HOME_CAT: '4bf58dd8d48988d103941735'
  USED_FB_KEYS: ['name', 'is_permanently_closed', 'is_unclaimed', 'cover', 'category_list', 'description', 'about'
                 'phone', 'founded', 'location', 'attire', 'price_range', 'were_here_count', 'likes', 'checkins',
                 'category', 'public_transit', 'payment_options', 'parking', 'culinary_team', 'general_manager',
                 'restaurant_services', 'restaurant_specialties', 'talking_about_count', 'id', 'link', 'is_community_page',
                 'website', 'can_post', 'has_added_app', 'is_published', 'username', 'hours', 'parent_page',
                 'mission', 'products', 'company_overview', 'awards', 'general_info']

  KNOWN_BITMASK_FIELDS:  [  # To find: 256
                          'PhoneNA',                          # 0   1
                          'AddressNA',                        # 1   2
                          'UrlNA',                            # 2   4
                          'CrossNA',                          # 3   8
                          'CityNA',                           # 4   16
                          'StateNA',                          # 5   32
                          'ZipNA',                            # 6   64
                          'TwitterNA',                        # 7   128
                          'PriceNA',                          # 9   512
                          'PrivateVenue',                     # 10  1024
                          'NoEvents',                         # 11  2048
                          'CountryCodeOverridden',            # 12  4096
                          'DontCanonicalizeAddress'           # 13  8192
                          'UserEnteredNeighborhoodAsCity',    # 14  16384
                          'UserEnteredSubhoodAsCity',         # 15  32768
                          'UserEnteredMacrohoodAsCity',       # 16  65536
                          'IsCityFromRevGeo',                 # 17  131072
                          'IsCountyFromRevGeo',               # 18  262144
                          'IsStateFromRevGeo',                # 19  524288
                          'UserEnteredNeighborhood',          # 20  1048576
                          'UserEnteredSubhood',               # 21  2097152
                          'UserEnteredMacrohood',             # 22  4194304
                          'UserEnteredCountyAsCity',          # 23  8388608
                          'IsServiceAreaBusiness',            # 25  33554432
                          'IsBlacklistedFromProactiveRecs',   # 26  67108864
                          'DontCheckPunctuationEmoji',        # 28  268435456
                        ]

  MAJOR_EDIT_FIELDS = ['address', 'categories', 'chainUrl', 'city', 'fbId', 'description', 'crossStreet',
                       'phone', 'hours', 'state', 'twitterName', 'url', 'userId', 'venuename', 'zip', 'latlng',
                       'deleted', 'closed', 'parentId']

  MAJOR_FLAG_TYPES: ["at", "category", "hours", "info", "missingaddress", "missingphone", "primarycategory", "remove",
                      "uncategorized", 'duplicate', 'manualDuplicate', 'removecategory', 'privatevenue', 'mislocated',
                      'publicvenue', 'unremove', 'editName', 'mi', 'menu']

  MINOR_FLAG_TYPES: ['suspicious', 'price', 'svd', 'explorespam', 'phrank', 'ph', 'tip', 'geo',
                     'suspicioushours', 'atvc', 'sv']

  KNOWN_REMOVE_REASONS: ['inappropriate', 'doesnt_exist', 'remove_home', 'event_over', 'closed', 'created_in_error', '']
  KNOWN_UNREMOVE_REASONS: ['notclosed', 'undelete']

  constructor: (@venuedata, @order) ->
    unless @venuedata
      throw "Tried to create a VenueResult without venue data"
    @id = @venuedata.id
    @createdAt = @venuedata.creationDate
    @existingFoursweepFlags = {}
    @listeners = new Listeners(['fullvenuecomplete', 'merged', 'gone', 'pulling-statuschanged', 'markedflagged',
                                'unmarkedflagged', 'pulling-edits-done', 'pulling-flags-done', 'pulling-full-done',
                                'pulling-foursweep-done', 'pulling-attributes-done', 'pulling-children-done',
                                'pulling-hours-done'])
    @currentDistance = @venuedata.location.distance || false
    @editHistory = []
    @pendingFlags = []
    @children = []
    @facebookDetails = null

    @venuedata.gone = false
    @venuedata.merged = false

    @setVenueStatus()

    @pulling = # states are: 'none', 'pulling', 'failed', 'done'
      edits: 'none'
      flags: 'none'
      full:  'none'
      foursweep: 'none'
      attributes: 'none'
      children: 'none'
      hours: 'none'

  auditDetails: () ->
    name: @venuedata.name
    location: @venuedata.location
    closed: @venuedata.closed?
    deleted: @venuedata.deleted?
    locked: @venuedata.locked?
    private: @venuedata.private?
    stats: @venuedata.stats
    categories: @venuedata.categories.map( (cat) -> {id: cat.id, name: cat.name})
    photos: {count: @venuedata.photos?.count}
    tips: {count: @venuedata.tips?.count}

  categories: () ->
    flags = (flag for own id, flag of @existingFoursweepFlags)

    removedCategoryIds = flags.filter (flag) ->
      flag.flag_type == "RemoveCategoryFlag"
    .map (flag) -> flag.itemId

    replaceAllCategoryIds = flags.filter (flags) ->
      flag.flag_type == "ReplaceAllCategoriesFlag"
    .map (flag) -> flag.itemId

    hasMakeHome = flags.filter((flags) -> flag.flag_type == "MakeHomeFlag").length > 0

    makePrimaryCategoryIds = flags.filter (flag) ->
      flag.flag_type == "MakePrimaryCategoryFlag"
    .map (flag) -> flag.itemId

    result = @venuedata.categories.map (e) =>
      e = $.extend {}, e #clone
      e.foursweepRemovePending = (e.id in removedCategoryIds) or
                                 (replaceAllCategoryIds.length > 0 && e.id not in replaceAllCategoryIds) or
                                 (hasMakeHome and e.id != @HOME_CAT)
      e.foursweepMakePrimaryPending = (e.id in makePrimaryCategoryIds) or
                                      (e.id in replaceAllCategoryIds) or
                                      (hasMakeHome and e.id == @HOME_CAT)
      e

    pending = flags.filter (flag) =>
      flag.flag_type in ["MakeHomeFlag", "ReplaceAllCategoriesFlag", "AddCategoryFlag", "MakePrimaryCategoryFlag"] and
      flag.itemId not in (@venuedata.categories.map (e) -> e.id)
    .map (e) ->
      name: e.itemName
      id: e.itemId

    return {
      existing: result
      pending: pending
    }

  # Return a negative number, 0, or a positive number if the VenueResult other
  # is before, equal to, or after this result, respectively
  compareTo: (other, field) ->
    switch field
      when 'createdat' then @id.localeCompare(other.id)
      when 'name' then @venuedata.name.localeCompare(other.venuedata.name)
      when 'namefuzzy' then @fuzzyName().localeCompare(other.fuzzyName())
      when 'address' then (@venuedata.location.address || "").localeCompare(other.venuedata.location.address || "")
      when 'checkins' then @venuedata.stats.checkinsCount - other.venuedata.stats.checkinsCount
      when 'users' then @venuedata.stats.usersCount - other.venuedata.stats.usersCount
      when 'distance' then @distance() - other.distance()
      when 'natural' then @order - other.order
      when 'category' then (@venuedata.categories[0]?.name || "").localeCompare(other.venuedata.categories[0]?.name || "")
      when 'herenow' then (@venuedata.hereNow?.count || 0) - (other.venuedata.hereNow?.count || 0)
      when 'phone' then (@venuedata.contact?.phone || "").localeCompare(other.venuedata.contact?.phone || "")
      when 'city' then (@venuedata.location?.city || "").localeCompare(other.venuedata.location?.city || "")
      else throw "Unknown field #{field}"

  createFlag: (type, extras = {}) ->
    flag =
      type: type
      venueId: @venuedata.id
      primaryName: @venuedata.name
      venues_details: [@auditDetails()]
    $.extend(flag, extras)

  createMergeFlag: (secondaryVenue, extras = {}) ->
    flag = @createFlag "MergeFlag",
      secondaryVenueId: secondaryVenue.id
      secondaryName: secondaryVenue.venuedata.name
      venues_details: [@auditDetails(), secondaryVenue.auditDetails()]
    $.extend flag, extras

  # Return last updated distance in meters, or, if unavailable,
  # the distance from the search location according to Foursquare,
  # or, failing that, false
  distance: () ->
    @currentDistance || @venuedata.location.distance || false

  distanceFromPoint: (point) ->
    google.maps.geometry.spherical.computeDistanceBetween @position(), point

  fuzzyName: () ->
    return @fuzzyNameCache if @fuzzyNameCache?
    # Returns a name devoid of beginning articles and with transliterations applied
    @fuzzyNameCache = FuzzyStringService.fuzzyString(@venuedata.name)

  getFacebookData: (options) ->
    return if @facebookDetails
    $.ajax
      dataType: 'json'
      url: "https://graph.facebook.com/#{@venuedata.contact.facebook}"
      success: (data) =>
        @facebookDetails = data
        for own key, val of @facebookDetails
          if key not in @USED_FB_KEYS
            console.log("UNUSED FB DATA", {venue: @venuedata.name, id: @id, key: key, val: val})
        options.success()
      error: () =>
        options.error()

  hasOldMajorFlags: () ->
    @majorFlags().filter( (e) -> e.isOld).length > 0

  majorEdits: () ->
    @editHistory.filter (e) -> !e.isMinor

  majorFlags: () ->
    # Effectively, sorting by id is sorting by date
    @pendingFlags.filter((e) -> !e.isMinor).sort (a,b) -> if a.id > b.id then -1 else 1

  markFlagged: (flag) ->
    @existingFoursweepFlags[flag.id] = flag
    @listeners.notify 'markedflagged', flag

  # Returns true if this venue matches all filter listed
  matchesAllFilter: (filters) ->
    for filter in filters
      return false if !filter.predicate(@venuedata)
    true

  photos: () ->
    @venuedata.photos?.groups.filter((e) -> e.type == 'venue')[0]?.items || []

  processAttributes: (response) ->
    @attributes = response
    @updatePullingStatus ['attributes'], 'done'

  processChildren: (response) ->
    @children = [].concat.apply [], response.children.groups.map (e) -> e.items
    @updatePullingStatus ['children'], 'done'

  processHours: (response) ->
    @hours = new Hours(response.hours?.timeframes || [])
    @updatePullingStatus ['hours'], 'done'

  processEditHistory: (response) ->
    # Edit delta names that we care about:

    @editHistory = response.items
    @knownEditCount = response.count

    for edit in @editHistory
      edit.isMinor = true
      edit.isMinor = false if edit.editType in ['create', 'merge', 'rollback']
      if edit.editType == 'create'
        @created =
          app: edit.app
          time: edit.createdAt
          user: edit.approvingUsers[0]
      for delta in edit.deltas
        if delta.name in MAJOR_EDIT_FIELDS
          edit.isMinor = false
        else
          if delta.name == 'flags'
            edit.isMinor = false if delta.new?.value?.match /PrivateVenue/
            [bitmask, texts...] = delta.new?.value?.split(/\s+/)
            for text in texts when text.replace("+", "").replace("-","") not in @KNOWN_BITMASK_FIELDS
              warn = "flags bitmask for #{text} (in #{texts}) found in #{@id}. old: #{delta.old.value}, new: #{delta.new.value}"
              console.log warn
    @updatePullingStatus ['edits'], 'done'

  processFullVenue: (response) ->
    oldvenuedata = @venuedata
    @venuedata = response
    @setVenueStatus()

    @listeners.notify "fullvenuecomplete", oldvenuedata
    @updatePullingStatus ['full'], 'done'

  processGone: ->
    @venuedata.deleted = true
    @venuedata.gone = true
    @listeners.notify "gone"

  processMerge: (newvenue) ->
    @venuedata.merged = true
    @listeners.notify "merged", newvenue

  processPendingFlags: (response) ->
    @pendingFlagCount = response.count
    @pendingFlags = response.items
    for flag in @pendingFlags
      flag.createdAt = parseInt(flag.id.slice(0,8), 16) * 1000
      flag.isOld = (new Date().getTime() - flag.createdAt) > 1000*60*60*24*30  # Older than 30 days?
      if flag.type in @MINOR_FLAG_TYPES
        flag.isMinor = true
      else if flag.type in @MAJOR_FLAG_TYPES
        if flag.type == 'at' and flag.value == undefined
          # Not sure why this happens, but we don't need to show empty attribute flags
          flag.isMinor = true
        else
          flag.isMinor = false
          if (flag.type == 'remove' and flag.value.reason and flag.value.reason not in @KNOWN_REMOVE_REASONS)
            warn = "encountered unknown remove reason #{flag.value.reason} in #{@id}"
            console.log warn, flag

          if (flag.type == 'unremove' and flag.value not in @KNOWN_UNREMOVE_REASONS)
            warn = "encountered unknown unremove reason #{flag.value} in #{@id}"
            console.log warn, flag

      else
        flag.isMinor = false
        warn = "encountered unknown flag type #{flag.type} found in #{@id}"
        console.log warn, flag
    @updatePullingStatus ['flags'], 'done'

  position: () ->
    new google.maps.LatLng(@venuedata.location.lat, @venuedata.location.lng)

  refreshEverything: (force = false) ->
    @refreshAlreadyFlaggedStatus(force)
    @upgradeWithFullData(force)

  refreshAlreadyFlaggedStatus: (force) ->
    @updatePullingStatus ['foursweep'], 'pulling'

    FlagSubmissionService.get().getAlreadyFlaggedStatuses [@id],
      type: 'venue'
      forcecheck: force
      success: (flags) =>
        @existingFoursweepFlags = {}
        for flag in (flags || [])
          @markFlagged(flag)
        @updatePullingStatus ['foursweep'], 'done'
      error: =>
        @updatePullingStatus ['foursweep'], 'failed'

  setVenueStatus: () ->
    @venuedata = $.extend @venuedata,
      home: @venuedata.categories[0]?.id == @HOME_CAT

  tips: () ->
    [].concat.apply [], @venuedata.tips?.groups.map (e) -> e.items

  topChildren: (n) ->
    return [] unless @children
    # Return top n children of this venue, if loaded.
    totalChildren: @children.length
    items: @children[0...n]
    remaining: Math.max(0, @children.length - n)

  undoMarkedFlagged: (flag) ->
    delete @existingFoursweepFlags[flag.id]
    @listeners.notify 'unmarkedflagged', flag

  updateDistance: (@currentDistance) ->

  updatePullingStatus: (fields = [], status) ->
    @pulling[field] = status for field in fields

    @listeners.notify "pulling-statuschanged", @pulling
    if status == 'done'
      for field in fields
        @listeners.notify "pulling-#{field}-done"

  upgradeWithFullData: (force = false) ->
    return if (@pulling.full != 'none' and @pulling.edits != 'none' and @pulling.flags != 'none') unless force
    @updatePullingStatus ['full', 'edits', 'flags', 'attributes', 'children'], 'pulling'

    $.ajax
      url: "https://api.foursquare.com/v2/multi"
      dataType: 'json'
      data:
        v: API_VERSION
        oauth_token: token
        m: 'swarm'  # Unless m=swarm, friendVisits returns odd results only from brands
        requests: ["/venues/#{@id}",
                   "/venues/#{@id}/flags?limit=20",
                   "/venues/#{@id}/edits?limit=20",
                   "/venues/#{@id}/attributes",
                   "/venues/#{@id}/children",
                   "/venues/#{@id}/hours"
                   ].join(',')
      success: (data) =>
        # Full Venue Response on responses[0]
        venueresponse = data.response.responses[0]
        if venueresponse.meta.code == 400 && venueresponse.meta.errorDetail.match /has been deleted/
          @processGone()
          @updatePullingStatus ['full', 'flags', 'edits', 'attributes', 'children'], 'done'
          return
        if venueresponse.meta.code == 200
          if venueresponse.response.venue.id != @venuedata.id
            # Venue has been merged
            @processMerge(venueresponse.response.venue)
            @updatePullingStatus ['full', 'flags', 'edits', 'attributes', 'children'], 'done'
            return
          else
            @processFullVenue(venueresponse.response.venue)
        else
          @updatePullingStatus ['full'], 'failed'

        # Flags returned on responses[1]
        if data.response.responses[1].meta.code == 200
          @processPendingFlags(data.response.responses[1].response.flags)
        else if data.response.responses[1].meta.errorType == 'not_authorized'
          @processPendingFlags({count: 0, items: []})
          # This is a home venue, it's not an error
        else
          @pendingFlags = []
          @pendingFlagCount = 0
          @updatePullingStatus ['flags'], 'failed'

        # Edit history on response[2]
        if data.response.responses[2].meta.code == 200
          @processEditHistory(data.response.responses[2].response.edits)
        else if data.response.responses[2].meta.errorType == 'not_authorized'
          @processEditHistory({count: 0, items: []})
        else
          @updatePullingStatus ['edits'], 'failed'

        if data.response.responses[3].meta.code == 200
          @processAttributes(data.response.responses[3].response)
        else if data.response.responses[3].meta.errorType == 'not_authorized'
          @updatePullingStatus ['attributes'], 'done'
        else
          @updatePullingStatus ['attributes'], 'failed'

        if data.response.responses[4].meta.code == 200
          @processChildren(data.response.responses[4].response)
        else if data.response.responses[4].meta.errorType == 'not_authorized'
          @updatePullingStatus ['children'], 'done'
        else
          @updatePullingStatus ['children'], 'failed'

        if data.response.responses[5].meta.code == 200
          @processHours(data.response.responses[5].response)
        else if data.response.responses[5].meta.errorType == 'not_authorized'
          @updatePullingStatus ['hours'], 'done'
        else
          @updatePullingStatus ['hours'], 'failed'

      error: () =>
        @updatePullingStatus ['full', 'edits', 'flags', 'attributes', 'children'], 'failed'

window.VenueResult = VenueResult
