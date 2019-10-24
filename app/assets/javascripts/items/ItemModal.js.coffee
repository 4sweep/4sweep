#= require search/SubmitListener
class ItemModal
  limit: 50
  HOME_CAT_ID: '4bf58dd8d48988d103941735'
  itemStats: {total: 0, deleted: 0, home: 0, private: 0, closed: 0, no_longer_relevant: 0}
  extraOptions: () -> {}

  loading: false
  hasMore: true
  nextOffset: 0
  alreadyflagged: null

  requestParams: () ->
    v: API_VERSION
    oauth_token: token
    m: "swarm"
    limit: @limit
    offset: @nextOffset

  constructor: (@source, @type) ->

  statusVisibility: () ->
    no_longer_relevant: @checkCookie("no_longer_relevant_visible")
    deleted: @checkCookie("deleted_visible")
    home: @checkCookie("home_visible")
    private: @checkCookie("private_visible")
    closed: @checkCookie("closed_visible")

  checkCookie: (cookiename) ->
    ($.cookie(cookiename) || "hidden") == "shown"

  clearItems: () ->
    @modal.find(".modal-body").html(HandlebarsTemplates["#{@type}s/grid"]())
    @nextOffset = 0
    @loading = false
    @hasMore = true
    @itemStats = {total: 0, deleted: 0, home: 0, private: 0, closed: 0, no_longer_relevant: 0}

  toggleMultiSelection: (startItem, endItem) ->
    range = [$(startItem).parents(".itemcontainer").index()..$(endItem).parents(".itemcontainer").index()]
    onOff = $(endItem).hasClass('selected')
    for i in @modal.find(".items .item:visible") when $(i).parents(".itemcontainer").index() in range
      $(i).toggleClass('selected', onOff)

  show: () ->
    $(".attach-modal").html(HandlebarsTemplates["#{@type}s/modal"]())
    @modal = $(".attach-modal ##{@type}modal")
    @modal.data('ItemModal', this)
    @modal.find(".modal-header").html(HandlebarsTemplates["#{@type}s/modal_header"]({source: @source, sourceType: @sourceType, statusVisibility: @statusVisibility()}))

    @clearItems()
    @lastClicked = undefined
    @modal.modal('show')
    @loadMore()
    @updateSelectedCount()
    self = this

    # Attach click to select event
    @modal.on "click", ".items .item", (e) ->
      return if $(e.target).is("a") or $(e.target).parent().is("a") or $(e.target).is(".zoomicon")
      e.preventDefault()
      $(this).toggleClass("selected")
      if e.shiftKey && self.lastClicked && sulevel >= 2
        self.toggleMultiSelection(self.lastClicked, this)

      self.updateSelectedCount()
      self.lastClicked = this

    # Attach load more on scroll event
    @modal.find(".modal-body").on "scroll", (e) ->
      if ($(this).scrollTop() + $(this).innerHeight() >= this.scrollHeight - 300 &&
          ($(this).scrollTop() > 50))
        self.loadMore()

    # Attach destroy event
    @modal.on "hidden", (e) ->
      return unless $(e.target).is(self.modal)
      self.destroy()

    # Attach action popovers
    @modal.find(".itemactions .item-popover-trigger").each (i, flag) ->
      context =
        problem: $(flag).children('a').data('problem'),
        problem_description: $(flag).children(".description").html()
        problem_text: $(flag).children('a').text()

      $(flag).popover({
        html: true,
        placement: 'bottom',
        title: () -> "Remove <span class='selected_count'></span> #{context['problem_text']} #{if self.type == 'photo' then "Photos" else "Tips"} " +
                     " <button class='popover-close close pull-right'>&times;</button>",
        content: () -> HandlebarsTemplates[self.type + "s/actions"](context),
        trigger: 'click',
      }).click (event) ->
        event.preventDefault()
        if $(this).children("a").hasClass("disabled")
          $(this).popover('hide')
          return
        $(".open-popover").not(flag).popover('hide')
        $(flag).addClass("open-popover")

    # Attach hide events to popover close buttons
    @modal.on "click",  ".popover-close",  (e) ->
      e.preventDefault()
      self.closePopovers()

    # Attach flag creation events:
    @modal.on "click", "button.itemflag", (e) ->
      e.preventDefault()
      self.createFlags($(this).data("flagtype"), $(this).data('problem'))

    # Attach filter
    @modal.on "keyup", ".itemfilter", (e) ->
      self.filterItems($(this).val())

    # Attach retry button
    @modal.on "click", "button.retry", (e) ->
      e.preventDefault()
      self.loading = false
      self.loadMore()
      self.modal.find(".retrytext .progress").removeClass("hide")

    # Attach listeners for changes on itemvisibles:
    @modal.find(".toggles .item_visible_toggle").click (e) ->
      e.preventDefault()
      newVis = if $(this).text() == "shown" then "hidden" else "shown"
      $(this).text(newVis)
      $.cookie($(this).data("visibility-type") + "_visible", newVis)
      self.toggleItemVisibility()

  filterItems: (filter = "") ->
    filter = filter.toLowerCase()
    self = this
    @modal.find(".item").each (i, e) ->
      $(e).toggleClass("hide", self.searchText($(e).data('item')).toLowerCase().indexOf(filter) == -1)

    if (@modal.find('.hasmore').length > 0 && !(@modal.find(".placeholder").hasClass("loading")) &&
        @modal.find(".hasmore").position().top < @modal.find(".modal-body").height())
      @modal.find(".placeholder").addClass("loading")
      self.loadMore()

  closePopovers: () ->
    @modal.find(".open-popover").popover('hide').removeClass("open-popover")

  hide: () ->
    @modal.modal('hide')

  destroy: () ->
    @clearItems()
    @modal.remove()

  updateSelectedCount: () ->
    count = @modal.find(".items .selected").length
    @modal.find(".selectedcount").text(count)
    @modal.find(".itemactions a").toggleClass('disabled', count == 0)
    if count == 0
      @modal.find(".actions button").attr('disabled', 'disabled')
    else
      @modal.find(".actions button").removeAttr('disabled')

  processItems: (items) ->
    @hasMore = items.items.length > 2
    @loading = false

    context = {source: @source, items: items}
    context['hasmoreclass'] = if @hasMore then 'hasmore' else 'nomore'
    context = $.extend(context, @extraOptions())

    @modal.find(".modal-body .placeholder").replaceWith(HandlebarsTemplates[@template](context))
    @nextOffset += @limit

    for item in items.items
      @modal.find(".item_#{item.id}").data('item', item)

    @markAlreadyFlagged()
    if @modal.find(".itemfilter").length > 0
      @filterItems(@modal.find(".itemfilter").val())

    if @sourceType == 'user'
      @itemVenueStatuses(items.items)
      @modal.find(".total_count").text(@itemStats.total)
      @modal.find(".deleted_count").text(@itemStats.deleted)
      @modal.find(".home_count").text(@itemStats.home)
      @modal.find(".private_count").text(@itemStats.private)
      @modal.find(".closed_count").text(@itemStats.closed)
      @modal.find(".no_longer_relevant_count").text(@itemStats.no_longer_relevant)

    @toggleItemVisibility()

    imagesLoaded(this.modal).on "always", (e) =>
      if (@modal.find(".placeholder").position().top - 50) < @modal.find(".modal-body").height()
        @loadMore()

  toggleItemVisibility: () ->
    statusVisibility = @statusVisibility()
    @modal.find(".item_home").parent(".itemcontainer").toggleClass("hide", not statusVisibility.home)
    @modal.find(".item_deleted").parent(".itemcontainer").toggleClass("hide", not statusVisibility.deleted)
    @modal.find(".item_closed").parent(".itemcontainer").toggleClass("hide", not statusVisibility.closed)
    @modal.find(".item_private").parent(".itemcontainer").toggleClass("hide", not statusVisibility.private)
    @modal.find(".item_no_longer_relevant").parent(".itemcontainer").toggleClass("hide", not statusVisibility.no_longer_relevant)

  itemVenueStatuses: (items) ->
    for item in items
      elem = @modal.find(".item_#{item.id}")
      @itemStats.total++
      unless item.venue
        @itemStats.deleted++
        elem.addClass("item_deleted")
      if item.venue?.private
        @itemStats.private++
        elem.addClass("item_private")
      if item.venue?.categories?[0]?.id == @HOME_CAT_ID
        @itemStats.home++
        elem.addClass("item_home")
      if item.venue?.closed
        @itemStats.closed++
        elem.addClass("item_closed")
      if "no_longer_relevant" in (item.flags || [])
        @itemStats.no_longer_relevant++
        elem.addClass("item_no_longer_relevant")

  loadMore: ->
    return if @loading or @hasMore == false
    @loading = true
    @modal.find(".placeholder").addClass("loading")

    $.ajax
      dataType: 'json'
      url: @loadUrl()
      success: (data) =>
        @processItems(@getItems(data))
      error: (xhr, textStatus, errorThrown) =>
        errorText = switch
          when xhr.status == 0 then "Could not connect to server, please check your network and try again."
          when xhr.status >= 500 and xhr.status then "A server error occurred, please try again later."
          when textStatus == 'timeout' then "The request timed out. Please try again."
          else
            # Rollbar.error("AJAX Items Modal Error: ", {xhr: xhr, textStatus: textStatus, errorThrown: errorThrown})
            "An unknown error occurred. Try again, and if the problem continues, please email foursweep@foursquare.com"
        @modal.find(".placeholder").html(HandlebarsTemplates['items/retry_placeholder']({errorText: errorText}))

      data: @requestParams()

  postSubmitProcess: (flag) ->
    i = @modal.find(".item_#{flag.itemId}")
    i.addClass('alreadyflagged', 500)
    i.removeClass("selected")
    if @alreadyflagged
      @alreadyflagged.push(flag.itemId)
    @updateSelectedCount()

  markAlreadyFlagged: () ->
    if (@alreadyflagged == null)
      # We have to pull these from the server
      sourceObj = switch @sourceType
        when "user" then {creator_ids: [@source.id]}
        when "venue" then {venue_ids: [@source.id]}

      FlagSubmissionService.get().getAlreadyFlaggedStatuses @source.id,
        success: (data) =>
          @alreadyflagged = data.map (e) -> e.itemId
          @markAlreadyFlagged()
        error: () -> # NOOP; fail silently on this
        type: @flagType
        fetchBy: switch @sourceType
                    when 'venue' then 'venue_ids'
                    when 'user' then 'creator_ids'
                    else throw "unknown type"
    else
      for id in @alreadyflagged
        @modal.find(".item_#{id}").addClass("alreadyflagged")

  createFlags: (flagType, problem) ->
    flags = []
    for item in @modal.find(".selected")
      data = $(item).data('item')

      if @sourceType == 'user'
        user = @source.user
        venue = new VenueResult(data.venue, 0)
      else if @sourceType == 'venue'
        user = data.user
        venue = @source

      continue unless venue

      flags.push venue.createFlag flagType,
        problem: problem
        itemId: data.id
        itemName: @itemName(data)
        comment: if $(".popover .comment") then $(".popover .comment").val() else ""
        creatorId: user.id
        creatorName: ((user.firstName || "") + " " + (user.lastName || "")).trim()

    FlagSubmissionService.get().submitFlags flags, new ItemsSubmitListener(this)

    @closePopovers()

  class ItemsSubmitListener extends SubmitListener
    constructor: (@itemModal) ->
    objectType: () ->
      switch @itemModal.flagType
        when 'PhotoFlag' then 'photos'
        when 'TipFlag' then 'tips'
    processSubmit: (flag) ->
      @itemModal.postSubmitProcess flag
    processUndo: (flag) ->
      # FIXME: should remove alreadyflagged status from element unless there are other pending flags

window.ItemModal = ItemModal
