#= require search/VenueActionPopovers/VenueActionPopover
#= require search/VenueActionPopovers/MultiVenueListener

class VenueFlagPopover extends VenueActionPopover
  requireSelectedCount: 1

  attach: () ->
    super()
    $('.attach-popover').on "click", ".addcomment", (e) ->
      e.preventDefault()
      $(this).hide()
      $(".attach-popover .commentfield").show().focus()
    @explorer.listeners.add 'submitautomaticallychanged', @setDescribeSubmitWhen

  setDescribeSubmitWhen: (automatic) ->
    if automatic
      $(".attach-popover .describesubmitwhen").html("Your flag will be automatically submitted after about 5 minutes. Until then, you can cancel it on the <a target='_blank' href='/flags?status=queued'>queued flags page</a>.")
    else
      $(".attach-popover .describesubmitwhen").html("When you're ready, review your flag and submit it on the <a target='_blank' href='/flags?status=new'>new flags page</a>.")

  showPopover: (e) ->
    super(e)
    self = this
    popoverelement = $(e).data('popover').tip()

    popoverelement.find(".btn.pushflag").click (e) ->
      e.preventDefault()
      return if $(this).hasClass("disabled")
      flags = self.createFlags(this)
      if extraConfirmation = self.requiresExtraConfirmation(flags, self.explorer.selected)
        self.showConfirmModal(flags, extraConfirmation)
      else
        FlagSubmissionService.get().submitFlags(flags, new MultiVenueListener(self.explorer.selected))
      self.trigger.popover('hide')

    @setDescribeSubmitWhen(FlagSubmissionService.get().runImmediatelyStatus())

  requiresExtraConfirmation: (flags) ->
    false

  createFlags: (button) ->
    flagtype = $(button).data('flagtype')

    # For single venue flags
    for venueid, venueelement of @explorer.selected
      venueelement.venueresult.createFlag flagtype,
        $.extend {problem: $(button).data('problem')}, @flagExtras()

  flagExtras: () ->
    popoverelement = @trigger.data('popover')?.tip()
    comment = popoverelement.find(".comment")?.val()?.trim()
    if comment
      {comment: comment}
    else
      {}

  showConfirmModal: (flags, extraConfirmation) ->
    self = this
    modalparent = $(".attach-modal").html HandlebarsTemplates["explore/massflags/confirm_modal"]
      extraConfirmation: extraConfirmation

    modal = $(modalparent).children('#confirmmodal')
    $(modal).find(".confirm").click (e) =>
      e.preventDefault()
      FlagSubmissionService.get().submitFlags(flags, new MultiVenueListener(self.explorer.selected))
      modal.modal('hide')

    $(modal).modal('show')

  requiresExtraConfirmationOnDistinctUsers: (flags = [], selected, distinctMin = 15) ->
    # A convenience function that subclasses can rely on to require a confirmation dialog when
    # flagging venues with a lot of unique users
    result = []

    for venueid, venueelement of selected when venueelement.venueresult.venuedata.stats.usersCount >= distinctMin
      venuedata = venueelement.venueresult.venuedata
      result.push "Venue <strong>#{venuedata.name}</strong> has been visited by <strong>#{venuedata.stats.usersCount}</strong> distinct users."

    if result.length > 0 then result else false

window.VenueFlagPopover = VenueFlagPopover
