class BootstrapUtils

  @repositionPopover: (popover) ->
    placement = popover.options.placement
    pos = popover.getPosition()

    actualWidth = popover.$tip[0].offsetWidth
    actualHeight = popover.$tip[0].offsetHeight

    tp = switch (placement)
      when 'bottom'
        {top: pos.top + pos.height, left: pos.left + pos.width / 2 - actualWidth / 2}
      when 'top'
        {top: pos.top - actualHeight, left: pos.left + pos.width / 2 - actualWidth / 2}
      when 'left'
        {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left - actualWidth - 7}
      when 'right'
        {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left + pos.width + 7}
    originaltop = tp.top

    popoverheight = popover.tip().height()
    if ((popoverheight + tp.top) > $(window).height())
      if placement != 'bottom'
        tp.top = $(window).height() - popoverheight - 10
      else
        popover.options.placement = 'top'
        return @repositionPopover(popover)
    if tp.top < 0 and placement != 'top'
      tp.top = 0

    if tp.top != originaltop
      popover.tip().find(".arrow").hide()
    popover.applyPlacement(tp, placement)

window.BootstrapUtils = BootstrapUtils
