#= require search/VenueActionPopovers/VenueFlagPopover
class CloseFlagPopover extends VenueFlagPopover
  template: "explore/massflags/close"
  tooltipTitle: () -> "Flag as Closed"
  title: () ->
    "Close <span class='selectedcount'>#{@selectedcount}</span> place(s):"
  showPopover: (e) ->
    super(e)
    popover = $(".attach-popover .popover")

    # Set up schedule close stuff
    popover.find(".btn.schedule").click (e) ->
      e.preventDefault()
      popover.find(".date").show();
      popover.find(".describesubmitwhen").hide()

    popover.find(".btn.immediate").click (e) ->
      e.preventDefault();
      popover.find(".date").hide()
      popover.find(".describesubmitwhen").show()

    popover.find(".date").datepicker(
      startDate: new Date()
    ).on 'changeDate', () ->
      popover.find(".date").datepicker('hide')

    popover.find(".date").change () =>
      val = popover.find("#scheduled_close").val()
      if @closeTime(val).isValid()
        popover.find(".closetext").text("Will submit " + @closeTime(val).format("llll (Z)"))
      else
        popover.find(".closetext").text("")

  closeTime: (val) ->
    moment(val, "YYYY-MM-DD").add(1, 'day').add(4, 'hour')

  flagExtras: () ->
    popover = @trigger.data('popover')?.tip()
    val = popover.find("#scheduled_close").val()

    extras = if (popover.find(".schedule.active").length > 0 and @closeTime(val).isValid())
      { scheduled_at: @closeTime(val).utc().toISOString() }
    else
      {}
    $.extend super(), extras

window.CloseFlagPopover = CloseFlagPopover
