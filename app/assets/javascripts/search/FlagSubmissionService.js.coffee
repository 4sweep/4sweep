# A service to submit flags to 4sweep's backend, produce notifications
# to users on successful (and failed) submissions.
#
# Also supports undoing flag submissions and running them immediately
class FlagSubmissionService
  @get: () ->
    @instance ?= new FlagSubmissionService()

  runImmediatelyStatus: () ->
    $(".submitautomatically").hasClass("active")

  # Takes an array of flags and a listener argument, which must be an object that
  # responds to he following calls:
  #   * objectType(): String the type of object that this flag represents, such as "venues", "tips", "photos", etc
  #   * processSubmit(flag)
  #   * processUndo(flag)
  #   * processRunImmediately(flag)
  submitFlags: (flags, listener) =>
    self = this
    submitnotice = if (flags.length >= 25)
      $.pnotify
        title: "Submitting flags"
        width: '450px'
        insert_brs: false
        type: "info"
        text: "This may take a few seconds"
        stack: @stackForObject(listener)
        addclass: @addclassForObject(listener)
        icon: false
        hide: false

    runimmediately = @runImmediatelyStatus()
    $.ajax
      type: "POST"
      url: "/flags"
      dataType: "json"
      data:
        flags: flags
        runimmediately: runimmediately
      success: (data) ->
        submitnotice?.pnotify_remove()
        self.displaySubmitSuccess(data, listener, submitnotice, runimmediately)
      error: @displaySubmitError

  displaySubmitError: (xhr, textStatus, errorThrown) ->
    errorText = switch
      when xhr.status == 0 then "Could not connect to server, please check your network and try again."
      when xhr.status >= 500 and xhr.status then "A server error occurred, please try again later."
      when textStatus == 'timeout' then "The request timed out. Please try again."
      else
        # Rollbar.error("AJAX error: ", {xhr: xhr, textStatus: textStatus, errorThrown: errorThrown})
        "An unknown error occurred. Try again, and if the problem continues, please email 4sweep@4sweep.com"
    $.pnotify
      title: "An error occurred"
      text: "\n" + errorText
      icon: false
      type: "error"
      width: '350px'

  displaySubmitSuccess: (data, listener, submitnotice, runimmediately) ->
    notify_text = ""
    type = listener.objectType()
    flag_cutoff = switch type
      when "venues" then 20
      when "tips" then 5
      when "photos" then 40
      else throw "Don't know this type (#{type})"

    notify_context =
      objectType: type
      description: data.flags[0]['friendly_name'] # This isn't technically correct, but all flags currently submitted are always of the same type
      top_flags: data.flags[0...flag_cutoff]
      total_count: data.flags.length
      remaining_flags_count: data.flags.length - flag_cutoff
      has_remaining: data.flags.length > flag_cutoff
      run_text: switch
        when data.flags[0]['scheduled_at'] != null
          "Your flag(s) will run " + moment(data.flags[0]['scheduled_at']).fromNow()
        when runimmediately
          "Your flag(s) will automatically run in about 5 minutes"
        when !runimmediately
          "Click on the <a target='_blank' href='/flags?status=new'>Flags Tab</a> to review and run your flags"
      compactView: (type == 'venues') and (data.flags.length == 1)

    notify_content = HandlebarsTemplates["explore/confirm_box"](notify_context)

    submitnotice?.pnotify_remove()

    notice = $.pnotify(
      title: HandlebarsTemplates["explore/confirm_title"](notify_context)
      width: '450px'
      icon: false
      insert_brs: false,
      type: "success",
      text: notify_content
      stack: @stackForObject(listener)
      addclass: @addclassForObject(listener)
    )

    self = this
    notice.find(".undoflags").click (e) ->
      e.preventDefault()
      return if $(this).hasClass("disabled")
      self.undoFlags(data.flags, listener)
      $(this).addClass("disabled").text("Canceling Flag")
      notice.find(".submitnow").addClass('disabled')

    notice.find(".submitnow").click (e) ->
      e.preventDefault()
      return if $(this).hasClass("disabled")
      self.submitImmediately(data.flags, listener)
      $(this).addClass("disabled").text("running now")
      notice.find(".undoflags").addClass('disabled')
      notice.pnotify_remove()

    notice.find(".reselect").click (e) ->
      e.preventDefault()
      listener.processReselect?()

    for flag in data.flags
      listener.processSubmit(flag)

    $("#flagcount").text(data.newcount)

  undoFlags: (flags, listener) ->
    $.ajax
      type: "POST"
      url: "/flags/cancel/"
      data:
        ids: flags.map (e) -> e.id
      success: () =>
        $.pnotify
          title: "Canceled #{flags.length} " + if flags.length > 1 then "flags" else "flag"
          type: "error"
          icon: false
          stack: @stackForObject(listener)
          addclass: @addclassForObject(listener)
          width: '450px'
        for flag in flags
          listener.processUndo(flag)
      error: () =>
        $.pnotify
          title: "Unable to cancel #{flags.length} " + if flags.length > 1 then "flags" else "flag"
          type: "error"
          icon: true
          stack: @stackForObject(listener)
          addclass: @addclassForObject(listener)
          width: '450px'

  submitImmediately: (flags, listener) ->
    $.ajax
      type: "POST"
      url: "/flags/run/"
      data:
        ids: flags.map (e) -> e.id
      success: () =>
        $.pnotify
          title: "Queued #{flags.length} " + (if flags.length > 1 then "flags" else "flag" ) + " for immediate processing"
          type: "success"
          icon: false
          stack: @stackForObject(listener)
          addclass: @addclassForObject(listener)
          width: '450px'
        for flag in flags
          listener.processRunImmediately(flag)
      error: () =>
        $.pnotify
          title: "Unable to immediately process " + (if flags.length > 1 then "flags" else "flag" )
          type: "error"
          icon: true
          stack: @stackForObject(listener)
          addclass: @addclassForObject(listener)
          width: '450px'

  stackForObject: (listener) ->
    if listener.objectType() == "venues"
      STACK_BOTTOMRIGHT
    else
      STACK_BOTTOMLEFT

  addclassForObject: (listener) ->
    if listener.objectType() == "venues"
      "stack-bottomright"
    else
      "stack-bottomleft"

  getAlreadyFlaggedStatuses: (itemIds, options = {}) ->
    flagTypes = switch options.type || "venue"
      when 'venue'
        ["MergeFlag", "DeleteFlag", "UndeleteFlag", "AddCategoryFlag",
        "MakePrimaryCategoryFlag", "RemoveCategoryFlag", "ReplaceAllCategoriesFlag",
        "CloseFlag", "ReopenFlag", "MakePrivateFlag", "MakePublicFlag", "MakeHomeFlag",
        "EditVenueFlag"]
      when 'TipFlag'
        ['TipFlag']
      when 'PhotoFlag'
        ['PhotoFlag']
      else throw Exception("Unknown type #{type} for getAlreadyFlaggedStatuses")
    data = {types: flagTypes}
    data[options.fetchBy || "venue_ids"] = itemIds
    data.forcecheck = true if options.forcecheck

    $.ajax
      type: "POST"
      url: '/flags/statuses'
      dataType: 'json'
      data: data
      success: options.success
      error: options.error

window.FlagSubmissionService = FlagSubmissionService
