class FlagsPopover
  constructor: (@venueResultElement, @attach) ->
    @venueresult = @venueResultElement.venueresult
    @setupFlagsPopover()
    @attach.click (e) =>
      e.preventDefault()

  toggleShown: () ->
    @attach.toggleClass("hide", @flagArray().length == 0)
    if @flagArray().length == 0
      popover = @attach.data('popover')?.tip()
      popover?.find('.arrow').hide()

  flagArray: () ->
    flag for own id, flag of @venueresult.existingFoursweepFlags

  setupFlagsPopover: () ->
    self = this
    @attach.popover
      html: true
      trigger: 'click'
      placement: 'right'
      title: () => "Pending 4sweep Flags for place: <em><a target='_blank' href='https://foursquare.com/venue/#{@venueresult.id}'>#{@venueresult.venuedata.name}</a></em>" + " <button class='popover-close close pull-right'>&times;</button>"
      content: () => HandlebarsTemplates['venues/pending_4sweep_flags']
        flags: @flagArray()
        venue: @venueresult.venuedata

      container: ".attach-popover"
      template: '<div class="popover ontop superwide"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>'
    .on "shown", (e) =>
      if $(e.target).hasClass('disabled')
        $(e.target).popover('hide')
        return
      @attach.addClass('active')
      BootstrapUtils.repositionPopover($(e.target).data('popover'))
      $(".open-popover").not(e.target).popover('hide')
      $(e.target).addClass("open-popover")
      popoverobj = $(e.target).data('popover')
      popover = popoverobj.tip()
      popover.find(".popover-close").click (e) ->
        e.preventDefault()
        popoverobj.hide()
      @setupActions(popover)

    .on "hidden", (e) =>
      @attach.removeClass('active')
      $(e.target).removeClass("open-popover")

  setupActions: (popover) ->
    popover.on "click", ".flagaction", (e) =>
      e.preventDefault()
      return if $(e.target).hasClass('disabled')
      $(e.target).addClass('disabled')
      flagid = $(e.target).parents(".flagrow").data('flagid')
      action = $(e.target).data('action')
      $.ajax
        type: "POST"
        url: "/flags/#{action}"
        data:
          ids: [flagid]
        success: (data) =>
          flag = data.flags[0].flag
          flagrow = popover.find("[data-flagid=#{flag.id}]")
          flagrow.html( Handlebars.partials['venues/_pending_4sweep_flag'](flag))
          if flag.status not in ['new', 'queued', 'scheduled', 'submitted']
            @venueresult.refreshEverything(true)
        error: () =>
          $(e.target).removeClass("disabled")
          $.pnotify
            title: "Error"
            type: "error"
            text: "\nAn error occurred during your last request. Please try again."
window.FlagsPopover = FlagsPopover
