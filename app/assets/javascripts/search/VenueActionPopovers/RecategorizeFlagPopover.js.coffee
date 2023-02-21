#= require search/VenueActionPopovers/VenueFlagPopover
class RecategorizeFlagPopover extends VenueFlagPopover
  template: "explore/massflags/recategorize"

  tooltipTitle: () -> "Change Category"

  title: () ->
    "Change categories for <span class='selectedcount'>#{@selectedcount}</span> place(s):"

  showPopover: (e) ->
    super(e)
    popover = @trigger.data('popover')?.tip()
    new CategorySelector().setupCategories popover.find(".cat-chooser"),
      allowMultiple: false
      recentChoicesSelector: popover.find(".recentlychosen")

    $(".recategorize-help").popover(
      html: true
      title: "Change Venue Categories"
      placement: "right"
      trigger: "hover"
      content: HandlebarsTemplates['explore/massflags/about_recategorize']()
    )

    popover.find(".cat-chooser").select2("focus")

  flagExtras: () ->
    popover = @trigger.data('popover')?.tip()
    extras =
      itemId: popover.find(".cat-chooser").select2('val')
      itemName: popover.find(".cat-chooser").select2('data')[0].text
    $.extend super(), extras

window.RecategorizeFlagPopover = RecategorizeFlagPopover
