class VenueActionPopover

  constructor: (@explorer, @trigger) ->
    @updatedSelectedCount(0, this)
    @explorer.listeners.add 'updatedselectedcount', (count) => @updatedSelectedCount(count, this)
    @trigger.parents(".massaction-tooltip").tooltip
      title: @tooltipTitle()
      placement: 'top'
      container: 'body'
      html: false

  attach: () ->
    self = this

    @trigger.click (e) -> e.preventDefault()

    @popover = @trigger.popover(
      html: true
      placement: 'bottom'
      title: () => @title() + @closeButton()
      content: () => @content()
      container: ".attach-popover"
    ).on("shown", (e) ->
      self.showPopover(this)
    ).on("hidden", (e) ->
      $(this).removeClass('open-popover')
    )

  tooltipTitle: () ->
    ""

  closeButton: () ->
    " <button class='popover-close close pull-right'>&times;</button>"

  updatedSelectedCount: (count, popover) ->
    popover.trigger.toggleClass "disabled", @requireSelectedCount > count
    popover.selectedcount = count

    popoverelement = $(popover.trigger).data('popover')?.tip()
    popoverelement?.find(".selectedcount").text(count)
    popoverelement?.find(".btn.pushflag").toggleClass 'disabled', @requireSelectedCount > count

  content: () ->
    HandlebarsTemplates[@template](@contentExtras())

  contentExtras: () -> {}

  showPopover: (e) ->
    # If this popover is disabled, hide it immediately
    if @trigger.hasClass('disabled')
      $(e).popover("hide")
      return
    # Close all other open popovers
    $(".open-popover").not(e).popover('hide')
    @trigger.addClass("open-popover")
    popoverelement = $(e).data('popover')?.tip()
    popoverelement.find(".popover-close").click (e) =>
      e.preventDefault()
      @trigger.popover('hide')

window.VenueActionPopover = VenueActionPopover
