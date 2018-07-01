# This class is essentially a controller for VenueResults, allowing
# users to interact with them and setting up the UI elements
# and interactivity for them
class VenueResultElement

  constructor: (@venueresult) ->
    @listeners = new Listeners ['selected', 'unselected', 'hidden', 'unhidden',
                                'requestzoomin', 'requestzoomout', 'multiselectionrequested',
                                'clicked', 'pin', 'unpin']
    @status =
      clicked: false
      hovering: false
      alreadyflagged: false
      filtered: false
      pinned: false
      hidden: false
      zoomhold: false

    @venueresult.listeners.add 'merged', (newvenue) => @displayMerged(newvenue)
    @venueresult.listeners.add 'gone', => @displayGone()
    @venueresult.listeners.add 'fullvenuecomplete', (oldvenuedata) => @displayFullVenue(oldvenuedata)
    @venueresult.listeners.add 'pulling-statuschanged', (statuses) => @displayPullStatus(statuses)
    @venueresult.listeners.add 'markedflagged', (flag) => @markFlagged(flag)
    @venueresult.listeners.add 'unmarkedflagged', (flag) => @undoMarkedFlagged(flag)
    @venueresult.listeners.add 'pulling-foursweep-done', () => @updateFlaggedStatus()

    @venueresult.listeners.add 'pulling-flags-done', () =>
      @elem.find(".pendingflagscontainer").html(Handlebars.partials["venues/parts/_pendingflagscount"]({flags: @venueresult.majorFlags()}))

    @venueresult.listeners.add 'pulling-edits-done', () =>
      @elem.find(".majoreditcontainer").html Handlebars.partials["venues/parts/_majoreditdate"]
        venue: @venueresult.venuedata
        majorEdits: @venueresult.majorEdits()
      @elem.find('.addressrow').html Handlebars.partials["venues/parts/_addressrow"]
        venue: @venueresult.venuedata
        created: @venueresult.created
        children: @venueresult.topChildren(0)

    @venueresult.listeners.add 'pulling-children-done', () =>
      @elem.find('.addressrow').html Handlebars.partials["venues/parts/_addressrow"]
        venue: @venueresult.venuedata
        created: @venueresult.created
        children: @venueresult.topChildren(0)

    @venueresult.listeners.add 'pulling-full-done', () =>
      @elem.find(".editdetails").toggleClass('disabled', @venueresult.pulling.full != 'done')

  applyFilters: (filters, toggles, map) ->
    before = @status.filtered
    @status.filtered = !@venueresult.matchesAllFilter(filters)
    @updateClasses if before != @status.filtered
    @toggleVisibilityByStatuses map, toggles

  createPinnedVersion: () ->
    @status.pinned = true

    vre = new VenueResultElement(@venueresult)
    vre.status = $.extend {}, @status

    vre.listeners = $.extend true, {}, @listeners
    vre.marker = @marker

    @listeners.add 'selected unselected', (e) =>
      vre.status.clicked = @status.clicked
      vre.updateClasses()

    vre.listeners.add 'selected unselected', (e) =>
      @status.clicked = vre.status.clicked
      @updateClasses()

    @listeners.add "unpin", (e) =>
      vre.status.pinned = false
      vre.listeners.notify "unpin"
      vre.updateClasses()

    vre.listeners.add "unpin", (e) =>
      @status.pinned = false
      @elem.find(".pinVenue").removeClass('active')
      @updateClasses()

    return vre

  compareTo: (other, type) ->
    @venueresult.compareTo(other.venueresult, type)

  displayCategories: () ->
    # Hide category popovers before replacing them so they aren't orphaned
    @elem.find(".categories .open-popover").popover('hide')
    @elem.find('.categories').html(Handlebars.partials["venues/parts/_categories"]({categories: @venueresult.categories()}))

  displayFullVenue: (oldvenuedata) ->
    @updateClasses()

    # FIXME: Add radius circles
    context =
      venue: @venueresult.venuedata
      distance: @venueresult.distance()
      status: @status

    @elem.find('.namerow').html(Handlebars.partials["venues/parts/_namerow"](context))
    @elem.find('.addressrow').html(Handlebars.partials["venues/parts/_addressrow"](context))
    @elem.find('.stats').html(Handlebars.partials["venues/parts/_statsrow"](context))

    @displayCategories()

    if oldvenuedata.location.lat != @venueresult.venuedata.location.lat or oldvenuedata.location.lng != @venueresult.venuedata.location.lng
      @marker.setPosition(@venueresult.position())

    # only do this if venue.closed, venue.deleted, venue.private changed
    if oldvenuedata.private? != @venueresult.venuedata.private? ||
       oldvenuedata.deleted? != @venueresult.venuedata.deleted? ||
       oldvenuedata.closed? != @venueresult.venuedata.closed?
      @elem.find('.venueactionscontainer').html(Handlebars.partials["venues/parts/_venueactions"](context))

    if oldvenuedata.categories[0]?.id != @venueresult.venuedata.categories[0]?.id
      @elem.find(".category-icon").html(Handlebars.partials["venues/parts/_categoryicon"](context))
      @updateIcon()

    @elem.find(".namerow [rel=tooltip]").tooltip()

  displayGone: ->
    @toggleHover(false)
    @showMarker(null)
    @elem.find('.namerow').html(Handlebars.partials["venues/parts/_namerow"](status: @status, venue: @venueresult.venuedata))
    @elem.find(".info .details").html(Handlebars.partials["venues/parts/_gone"]({venue: @venueresult.venuedata}))
    @elem.find(".open-popover").popover('hide')
    @updateClasses()


  displayMerged: (newvenue) ->
    @toggleHover(false)
    @showMarker(null) # Marker needs to be removed
    @elem.find('.namerow').html(Handlebars.partials["venues/parts/_namerow"](status: @status, venue: @venueresult.venuedata))
    @elem.find(".info .details").html(Handlebars.partials["venues/parts/_merged"](newvenue: newvenue, venue: @venueresult.venuedata))
    @elem.find(".open-popover").popover('hide')
    @updateClasses()

  displayPullStatus: (pullStatuses) ->
    allstatuses = (s for own k,s of pullStatuses)
    if 'failed' in allstatuses and 'pulling' not in allstatuses
      @elem?.find(".refreshEverything").removeClass('btn-info').addClass('btn-warning')
      @elem?.find(".refreshEverything i").tooltip
        trigger: 'manual'
        placement: 'bottom'
        title: "Failed to load some additional venue data. Click this button to try again."
      .tooltip("show")
      window.setTimeout( (() => @elem?.find(".refreshEverything i").tooltip('hide')), 4500)
    else
      @elem?.find(".refreshEverything").addClass('btn-info').removeClass('btn-warning')

    @elem?.find(".refreshEverything i").toggleClass 'animate-spin', 'pulling' in allstatuses

  hide: () ->
    return if @status.hidden
    @elem.hide()
    @status.hidden = true
    @listeners.notify "hidden"
    @marker.setMap(null)
    if @status.clicked and !@status.pinned
      @status.reselectOnUnhide = true
      @toggleSelection(false)

  # type is a string that can be any of:
  #   "default": a normal gray icon
  #   "alreadyflagged": grayed out icon
  #   "hovering": green icon indicating venue is being hovered over
  #   "clicked": orange icon indicating venue has been selected
  iconUrl: (type = "default") ->
    url = if @venueresult.venuedata.categories.length > 0
      @venueresult.venuedata.categories[0].icon.prefix.replace(/^.*\/img\/categories_v2\//, "https://s3.amazonaws.com/4sweep-assets/") + "32_bordered.png" # REPLACE_ME
    else
      "https://s3.amazonaws.com/4sweep-assets/none_32_bordered.png" # REPLACE_ME

    typestr = switch type
      when "default" then "bordered"
      when "clicked" then "orange"
      when "hovering" then "green"
      when "alreadyflagged" then "faded"
      else throw("Don't know type #{type}")

    url.replace(/32_[a-z]+.png/, "32_#{typestr}.png")

  isHidden: () ->
    @status['hidden']

  isVisible: () ->
    @elem.is(":visible")

  markFlagged: (flag) ->
    @updateFlaggedStatus()
    @toggleSelection() if @status.clicked
    @displayCategories()
    @setupFlagsPopover()

  remove: () ->
    @elem.find(".open-popover").popover('hide')
    @elem.remove()
    @showMarker(null) unless @status.pinned
    # FIXME: remove venue radius circles if present

  render: () ->
    @elem = $ HandlebarsTemplates['venues/venue_item']
      venue: @venueresult.venuedata
      status: @status
      distance: @venueresult.distance()
      flags: @venueresult.majorFlags()
      majorEdits: @venueresult.majorEdits()
      created: @venueresult.created
      children: @venueresult.topChildren(0)
      pulling: @venueresult.pulling
      categories: @venueresult.categories()

    self = this
    @elem.on 'click', (e) ->
      return if self.elem.find("a").children().is($(e.target)) or self.elem.find("a").is($(e.target)) or
                self.elem.find(".full_category").is($(e.target))  # Ignore even if happened on a link
      self.toggleSelection()
      if e.shiftKey
        self.listeners.notify "multiselectionrequested", self
      self.listeners.notify "clicked", self

    @elem.hover( (() => @toggleHover(true)), (() => @toggleHover(false)))

    @elem.on "click", "a.flag", (e) ->
      e.preventDefault()
      flag = self.venueresult.createFlag($(this).data('flagtype'), {problem: $(this).data('problem')})
      FlagSubmissionService.get().submitFlags([flag], new VenueSubmitListener(self))

    @elem.on "click", ".refreshEverything", (e) ->
      e.preventDefault()
      self.elem.find('.refreshEverything i').tooltip('hide')
      self.venueresult.refreshEverything(true)

    @elem.on "click", ".pinVenue", (e) =>
      e.preventDefault()
      if @status.pinned
        @status.pinned = false
        @listeners.notify "unpin"
        @elem.find(".pinVenue").removeClass("active")
      else
        toPin = @createPinnedVersion()
        @listeners.notify "pin", toPin
        @elem.find(".pinVenue").addClass("active")
      @updateClasses()

    @setupHoverPopover
      attachselector: '.photocountcontainer'
      hoverselector: '.photocount.hasphotos'
      content: () => HandlebarsTemplates['venues/venue_photos_preview']({photos: self.venueresult.photos()[0..6]})
      title: () => "Top photos at #{self.venueresult.venuedata.name} (click to edit)"
      arrow: true
      runAfterHover: (e) =>
        $(e.target).data('popover').tip().find("img").on('load', () => BootstrapUtils.repositionPopover($(e.target).data('popover')))

    @setupHoverPopover
      attachselector: ".tipcountcontainer"
      hoverselector: ".tipscount.hastips"
      content: () => HandlebarsTemplates['venues/venue_tips_preview']({tips: self.venueresult.tips()[0..6]})
      title: () => "Popular Tips at #{self.venueresult.venuedata.name} (click to edit)"

    @setupHoverPopover
      attachselector: ".listedcountcontainer"
      hoverselector: ".listcount.islisted"
      content: () => HandlebarsTemplates['venues/venue_listed_preview']({lists: self.venueresult.venuedata.listed})
      title: () => "Lists that include #{self.venueresult.venuedata.name}"

    @setupHoverPopover
      attachselector: ".majoreditcontainer"
      hoverselector: ".lasteditdate"
      content: () => HandlebarsTemplates['venues/edit_history']({venue: @venueresult.venuedata, edits: @venueresult.editHistory[0...5], editsCount: @venueresult.knownEditCount})
      title: () => "Recent Edits at #{self.venueresult.venuedata.name} (click for more)"
      arrow: false
      widthClass: 'superduperwide'

    @setupHoverPopover
      attachselector: ".pendingflagscontainer"
      hoverselector: ".pendingflagcount"
      content: () => HandlebarsTemplates['venues/pending_flags']
        flags: @venueresult.majorFlags()
        flagsCount: @venueresult.pendingFlagCount
        venue: @venueresult.venuedata
        hasOldMajorFlags: @venueresult.hasOldMajorFlags()
      title: () => HandlebarsTemplates['venues/pending_flags_title']({venue: @venueresult.venuedata})
      arrow: true
      clicktokeep: true

    @setupHoverPopover
      attachselector: '.facebooklinkcontainer'
      hoverselector: ".facebooklink"
      content: () => HandlebarsTemplates['venues/facebook_details']
        venue: @venueresult.venuedata
        facebook: @venueresult.facebookDetails
      title: () => HandlebarsTemplates['venues/facebook_popover_title']
        venue: @venueresult.venuedata
      arrow: true
      widthClass: "superduperwide"
      clicktokeep: true
      runAfterHover: (e) => @venueresult.getFacebookData
        success: =>
          popover = $(e.target)
          popover.data('popover').tip().find(".popover-content").html(
            HandlebarsTemplates['venues/facebook_details']({venue: @venueresult.venuedata, facebook: @venueresult.facebookDetails})
          )
          BootstrapUtils.repositionPopover($(e.target).data('popover'))
          popover.data('popover').tip().find(".popover-close").click (e) ->
            e.preventDefault()
            popover.popover('hide')
        error: =>
          popover = $(e.target)
          popover.data('popover').tip().find(".popover-content").html(
            HandlebarsTemplates['venues/facebookload_failed']()
          )
          popover.data('popover').tip().find(".popover-close").click (e) ->
            e.preventDefault()
            popover.popover('hide')

    @elem.hoverIntent(
      () => @venueresult.upgradeWithFullData(false),
      () =>
    )

    @setupDetailsPopovers()
    @setupCategoryEditEvents()
    new DetailsEditor(this, @elem.find(".editdetails"))
    @setupFlagsPopover()
    @setupZoom()

    @setupMarker()
    @elem.hide() if @status.hidden

    @elem.find(".venuebuttons [rel=tooltip]").tooltip()

    @elem.on "click", ".photocount", (e) =>
      e.preventDefault()
      photomodal = new VenuePhotoModal(@venueresult)
      photomodal.show()

    @elem.on "click", ".tipscount", (e) =>
      e.preventDefault()
      tipmodal = new VenueTipModal(@venueresult)
      tipmodal.show()
    @elem.find(".namerow [rel=tooltip]").tooltip()

    @elem

  setupDetailsPopovers: () ->
    self = this
    @setupHoverPopover
      attachselector: ".descriptioncontainer"
      hoverselector: ".foursquare-description.present"
      content: () => HandlebarsTemplates['venues/details/description']({venue: @venueresult.venuedata})
      title: () => "Description of #{self.venueresult.venuedata.name}"
      placement: 'bottom'
    @setupHoverPopover
      attachselector: ".hourscontainer"
      hoverselector: ".foursquare-hours.present"
      content: () => HandlebarsTemplates['venues/details/hours']({venue: @venueresult.venuedata})
      title: () => "Hours at #{self.venueresult.venuedata.name}"
      placement: 'bottom'
    @setupHoverPopover
      attachselector: ".userscontainer"
      hoverselector: ".foursquare-users.present"
      content: () => HandlebarsTemplates['venues/details/users']({venue: @venueresult.venuedata})
      title: () => "People at #{self.venueresult.venuedata.name}"
      placement: 'bottom'
    @setupHoverPopover
      attachselector: ".attributescontainer"
      hoverselector: ".foursquare-attributes.present"
      widthClass: "superduperwide"
      content: () => HandlebarsTemplates['venues/details/attributes']({venue: @venueresult.venuedata, attributes: @venueresult.attributes})
      title: () => "Attributes at #{self.venueresult.venuedata.name}"
      placement: 'bottom'
    @setupHoverPopover
      attachselector: ".createdcontainer"
      hoverselector: ".foursquare-created.present"
      # widthClass: "superduperwide"
      content: () => HandlebarsTemplates['venues/details/created']({venue: @venueresult.venuedata, created: @venueresult.created})
      title: () => "Creator of #{self.venueresult.venuedata.name} (click for more venues created by this user)"
      placement: 'bottom'
    @setupHoverPopover
      attachselector: ".childrencontainer"
      hoverselector: ".foursquare-children.present"
      widthClass: "superduperwide"
      arrow: true
      content: () => HandlebarsTemplates['venues/details/children']({venue: @venueresult.venuedata, children: @venueresult.topChildren(16)})
      title: () => "Places inside #{self.venueresult.venuedata.name}"
      placement: 'right'
    @setupHoverPopover
      attachselector: ".chaincontainer"
      hoverselector: ".foursquare-chain.present"
      content: () => HandlebarsTemplates['search_extras/userextras']($.extend @venueresult.venuedata.page.user, {"storeId": @venueresult.venuedata.storeId})
      title: () => "Chain information for #{self.venueresult.venuedata.name} (click for more venues)"
      placement: 'bottom'

  setupCategoryEditEvents: () ->
    self = this
    @elem.find(".categories").popover(
      selector: ".full_category"
      content: () ->
        HandlebarsTemplates['venues/category_edit_popover']({venue: self.venueresult.venuedata, category_name: $(this).text(), category_primary: $(this).data('primary')})
      title: () ->
        HandlebarsTemplates['venues/category_edit_popover_title']({category_name: $(this).text()})
      html: true
      trigger: "click"
      position: "right"
      container: 'body'
    ).on("shown", (e) ->
      $(e.target).addClass("open-popover")

      $(".open-popover").not(e.target).popover('hide')

      popover = $(e.target).data('popover')
      popover.tip().find(".close").click (click) -> popover.hide()
      popover.tip().find(".flagbutton").click (click) ->
        e.preventDefault()
        return if $(this).hasClass('disabled')

        flag = self.venueresult.createFlag $(this).data('flagtype'),
          itemId: $(e.target).data('catid')
          itemName: $(e.target).text()

        FlagSubmissionService.get().submitFlags [flag], new VenueSubmitListener(self)
        popover.hide()

    ).on("hidden", (e) ->
      $(e.target).removeClass("open-popover")
    )

  setupFlagsPopover: () ->
    (@flagPopover ||= new FlagsPopover(this, @elem.find(".foursweepflagsbutton"))).toggleShown()

  # Set up a popover on this element that happens via popover on a dynamic selector.
  # It seems that some bootstrap bug I can't work around prevents trigger: "hover" with selector if
  # that selector is dynamically added after attaching the popover
  #
  # options:
  #   'attachselector'
  #   'hoverselector'
  #   'title'
  #   'content'
  #   'arrow'
  #   'clicktokeep'
  setupHoverPopover: (options) ->
    arrowDiv = if options.arrow? then 'arrow' else ''
    widthclass = if options.widthClass? then options.widthClass else 'superwide'
    @elem.find(options.attachselector).click (e) ->
      e.preventDefault() if ($(e.target).parents('a').attr('href') == '#') || ($(e.target).is("a") && $(e.target).attr('href') == '#')

    attachelem = @elem.find(options.attachselector)
    attachelem.popover
      trigger: "manual"  # Hover doesn't work, we have to use a workaround
      selector: options.hoverselector
      html: true
      title: options.title
      content: options.content
      placement: options.placement || 'right'
      template: '<div class="popover ontop ' + widthclass + '"><div class="' + arrowDiv + '"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>'
      container: ".attach-widepopover"
    .on "shown", (e) ->
      e.stopPropagation()
      $(e.target).addClass("open-popover")
      popover = $(e.target).data('popover')
      BootstrapUtils.repositionPopover(popover)
      popover.tip().find('.popover-close').click (e) ->
        e.preventDefault()
        attachelem.popover('hide')
      options.runAfterHover(e) if (options.runAfterHover)
    .on "hidden", (e) =>
      e.stopPropagation()
      $(e.target).removeClass('open-popover')
      attachelem.data('openstate', '')

    if options.clicktokeep == true
      attachelem.on "click", options.hoverselector, (e) =>
        if attachelem.data('openstate') == 'clicked'
          attachelem.popover('hide')
        else
          attachelem.data('openstate', 'clicked')
          attachelem.popover('show') unless attachelem.hasClass('open-popover')
          attachelem.data('popover').tip().addClass('openstate-clicked').removeClass('openstate-hover')
          BootstrapUtils.repositionPopover(attachelem.data('popover'))

    attachelem.on "mouseenter mouseleave", options.hoverselector, (e) =>
      if (attachelem.data('openstate') != 'clicked')
        attachelem.popover(if (e.type == 'mouseenter') then 'show' else 'hide')
        attachelem.data('openstate', if (e.type == 'mouseenter') then 'hover' else '')
        attachelem.data('popover').tip().removeClass('openstate-clicked').addClass('openstate-hover')

  setupMarker: () ->
    unless @marker
      @marker = new google.maps.Marker
        position: @venueresult.position()
        icon:
          anchor: new google.maps.Point(10,10) # Anchor in center of icon
          size: new google.maps.Size(32,32)
          scaledSize: new google.maps.Size(20,20)
          url: @iconUrl("default")
        title: @venueresult.venuedata.name
        zIndex: 15
        draggable: false
        clickable: true

    google.maps.event.addListener @marker, 'mouseover', => @elem.addClass("hoveronicon"); @toggleHover(true)
    google.maps.event.addListener @marker, 'mouseout',  => @elem.removeClass("hoveronicon"); @toggleHover(false)

  setupZoom: () ->
    zoombutton = @elem.find(".zoomtovenue")
    zoombutton.hoverIntent(
      () =>
        @listeners.notify "requestzoomin" unless @status.zoomhold
        @status.zoomHover = true
      ,() =>
        @listeners.notify "requestzoomout" unless @status.zoomhold
        @status.zoomHover = false
    )

    zoombutton.click (e) =>
      @status.zoomhold = !@status.zoomhold
      zoombutton.toggleClass("active", @status.zoomhold)
      @listeners.notify (if @status.zoomhold then "requestzoomin" else "requestzoomout")

  setZoomState: (zoomstate) ->
    @status.zoomhold = zoomstate
    @elem.find(".zoomtovenue").toggleClass('active', zoomstate)

  showMarker: (map) ->
    if @venueresult.gone or @venueresult.merged
      @marker.setMap(null)
    else
      @marker.setMap(map)

  toggleHover: (hoveringIn) ->
    return if (@venueresult.venuedata.gone or @venueresult.venuedata.merged) and hoveringIn and !@status.hovering # Allow hoverout if necessary on merge
    @status.hovering = hoveringIn
    @elem.toggleClass("hovering", hoveringIn)
    @updateIcon()
    # @listeners.notify (if @status.hovering then 'hoverin' else 'hoverout'), this

  toggleSelection: (onOff) ->
    if @venueresult.venuedata.merged or @venueresult.venuedata.gone
      onOff = false
    @status.clicked = if onOff == undefined then !@status.clicked else onOff
    @elem.toggleClass("clicked", @status.clicked)
    @updateIcon()
    @listeners.notify (if @status.clicked then 'selected' else 'unselected'), this

  toggleVisibilityByStatuses: (map, toggles) ->
    toggles = $.extend toggles, {filtered: false} # always hide filtered values
    for own name, show of toggles when show is false and (@status[name] is true or @venueresult.venuedata[name] is true)
      @hide()
      return false
    @unhide(map); true

  undoMarkedFlagged: (flag) ->
    @updateFlaggedStatus()
    @displayCategories()
    @setupFlagsPopover()

  unhide: (map) ->
    return unless @status.hidden
    @elem?.show()
    @status.hidden = false
    @listeners.notify "unhidden"
    @showMarker map
    if @status.reselectOnUnhide
      @toggleSelection(true)
    delete @status.reselectOnUnhide

  updateClasses: () ->
    @elem.attr('class', Handlebars.partials["venues/parts/_venueclasses"]({status: @status, venue: @venueresult.venuedata}))

  updateDistance: (newCenter) ->
    distance = @venueresult.distanceFromPoint(newCenter)
    @venueresult.updateDistance(distance)
    @elem.find(".distance").text("[" + Math.round(distance).toLocaleString() + " m]")

  updateIcon: () ->
    iconChoice = 'default'

    for s in ['clicked', 'hovering', 'alreadyflagged'] # Select icon in this order, if multiple are true
      if @status[s]
        iconChoice = s
        break

    @marker.setIcon
      anchor: new google.maps.Point(10,10)
      url: @iconUrl(iconChoice)
      size: new google.maps.Size(32,32)
      scaledSize: new google.maps.Size(20,20)

    switch iconChoice
      when 'hovering' then @marker.setZIndex(25)
      when 'clicked' then @marker.setZIndex(20)
      else @marker.setZIndex(15)

  updateFlaggedStatus: () ->
    @status.alreadyflagged = (k for k of @venueresult.existingFoursweepFlags).length isnt 0
    @elem.toggleClass("alreadyflagged", @status.alreadyflagged, 500)
    @updateIcon()
    @displayCategories()
    @setupFlagsPopover()


window.VenueResultElement = VenueResultElement
