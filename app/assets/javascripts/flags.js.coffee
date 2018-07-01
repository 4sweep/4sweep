# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$().ready ->
  setupListeners()
  updateQueueButtons(true)
  setupTooltips()
  setupPagesize()
  setupPhotoPopover()
  setupFilterButton()
  $(".statuschange").click( (e) ->
    e.preventDefault()
    updateUrlParams({'status': $(this).data('status'), 'page': 1})
  )

queues = {
  check: {
    items: [],
    running: false,
    processingtext: "Checking",
    processedtext: "Checked",
    runtext: "Check",
    action: "check",
    allbuttonclass: ".checkall",
    btnclass: ".flagcheck",
    process_size: 8
  },
  submit: {
    items: [],
    running: false,
    processingtext: "Submitting",
    processedtext: "Submitted",
    runtext: "Run",
    action: "run",
    allbuttonclass: ".runall",
    btnclass: ".flagrun",
    process_size: 50
  },
  cancel: {
    items: [],
    running: false,
    processingtext: "Canceling",
    processedtext: "Canceled",
    runtext: "Cancel",
    action: "cancel",
    allbuttonclass: ".cancelall",
    btnclass: ".flagcancel",
    process_size: 10
  },
  resubmit: {
    items: [],
    running: false,
    processingtext: "Resubmitting",
    processedtext: "Resubmitted",
    runtext: "Resubmit",
    action: "resubmit",
    allbuttonclass: ".resubmitall",
    btnclass: ".flagresubmit",
    process_size: 2
  }
  hide: {
    items: [],
    running: false,
    processingtext: "Hiding",
    processedtext: "Hidden",
    runtext: "Resubmit",
    action: "hide",
    allbuttonclass: ".hideall",
    btnclass: ".flaghide",
    process_size: 5
  }
}


createAndRunFlag = (flag) ->
  $.ajax(
    type: "POST"
    url: '/flags'
    dataType: 'json'
    data:
      flags: [flag],
      runimmediately: true
    success: (data) ->
      result = data.flags[0]
  )

friendlyStatus = (status, details) ->
  friendly = switch status
    when 'not_authorized' then "Not authorized"
    when 'new' then "Not yet submitted"
    when 'resolved' then 'Accepted'
    when 'cancelled' then "Canceled"
    when 'canceled' then "Canceled"
    when 'submitted' then "Submitted"
    when 'hidden' then "Hidden"
    when 'queued' then "Queued"
    when 'scheduled' then "Scheduled"
    when 'failed' then 'Failed'
    else status

  if details
    return "#{friendly} #{details}"
  else
    return friendly

setupPagesize = ->
  $(".pagesize").change (e) ->
    e.preventDefault()
    updateUrlParams({'pagesize': $(".pagesize").val(), 'page': 1})

updateActions = (flag) ->
  flagid = flag.id
  status = flag.status

  $("#flagrow_#{flagid} .flaghide").tooltip('hide')
  if status == 'resolved'
    $("#flagrow_#{flagid} .flagcheck").remove()
    $("#flagrow_#{flagid} .flagrun").remove()
    $("#flagrow_#{flagid} .flagresubmit").remove()
    $("#flagrow_#{flagid} .flaghide").remove()

  if status != 'new' and status != 'queued' and status != 'scheduled'
    $("#flagrow_#{flagid} .flagcancel").remove()
    $("#flagrow_#{flagid} .flagrun").remove()

  if status == 'cancelled' or status == 'canceled'
    $("#flagrow_#{flagid} .flagcheck").remove()
    $("#flagrow_#{flagid} .flagcancel").remove()
    $("#flagrow_#{flagid} .flagrun").remove()
    $("#flagrow_#{flagid} .flaghide").remove()

  if status == 'hidden'
    $("#flagrow_#{flagid} .flagcheck").remove()
    $("#flagrow_#{flagid} .flagrun").remove()
    $("#flagrow_#{flagid} .flagresubmit").remove()
    $("#flagrow_#{flagid} .flaghide").remove()


updateQueueButtons = (firstrun) ->
  $("#queuebuttons").removeClass('hidden')

  for i in ['submit', 'check', 'cancel']
    queue = queues[i]
    left = $(queue.btnclass).length

    $(queue.allbuttonclass).text("#{queue.runtext} all flags on this page (" +  left  + ")")

    if left == 0
      if !firstrun
        # $(queue.allbuttonclass).text("Complete!").removeClass("btn-primary").addClass("btn-success")
        $(queue.allbuttonclass).delay(1500).fadeOut()
      else
        $(queue.allbuttonclass).remove()


@friendlyDate = (timestamp) ->
  if timestamp
    moment(new Date(timestamp)).calendar()
  else
    "-"

@futureFriendlyDate = (timestamp) ->
  if timestamp
    return moment(timestamp).calendar()
  else
    "-"

runQueue = (name) ->
  queue = queues[name]
  return if queue.running # i think this is a good enough mutex in JS

  queue.running = true
  processsize = queue.process_size
  flagids = []
  while ((processsize-- > 0) && (queueitem = queue.items.shift()))
    flagids.push($(queueitem).data('flagid'))
    $(queueitem).text(queue.processingtext + "...")

  startTime = new Date().getTime()
  $.ajax
    type: "POST"
    url: "/flags/#{queue.action}/"
    data: {ids: flagids}
    success: (data) ->
      queue.running = false

      $(data.flags).each (i, flagresponse) ->
        flag = flagresponse.flag
        flagid = flag.id
        target = $("#flagrow_#{flagid} #{queue.btnclass}")
        if flagresponse.message
          $("#flagrow_#{flagid} .status").text(flagresponse.message)
          $(target).text(queue.runtext)
          $(target).removeClass("disabled")
        else
          $("#flagrow_#{flagid} .status").text(friendlyStatus(flag.status, flag?.resolved_details))

        $("#flagrow_#{flagid} .last_checked").html(friendlyDate(flag?.last_checked))

        $("#flagrow_#{flagid} .last_checked").effect('highlight')
        $(target).text(queue.processedtext)

        $("#flagrow_#{flagid} .status").effect('highlight')
        if (name == 'submit' and flag.status == 'submitted')
          setTimeout( () ->
            $("#flagrow_#{flagid} .flagcheck").click()
          , 8000)

        updateActions(flag)

      if data.newcount == 0
        $("#flagcount").remove()
      else
        $("#flagcount").text(data.newcount)

      updateQueueButtons(false)

      if queue.items.length > 0
        runQueue(name)
    error:  (jqXHR, textStatus, errorThrown) ->
      if jqXHR.readyState >= 4 # Request not yet sent, likely user navigated away
        # Rollbar.error("Error on executing #{queue.action}: ", textStatus, errorThrown, flagids, jqXHR.responseText)
        alert("Stopped due to error: " + errorThrown)
      queue.running = false

setupQueueListeners = (name) ->
  queue = queues[name]
  $(queue.btnclass).click (e) ->
    e.preventDefault()
    $(e.target).addClass("disabled")
    queue.items.push($(e.target))
    setTimeout( (() -> runQueue(name)), 100)

setupListeners = ->
  for i in ['submit', 'cancel', 'check', 'resubmit', 'hide']
    setupQueueListeners(i)

  $(".runall").click (e) ->
    e.preventDefault()
    $(".flagrun").click()
    $(e.target).addClass('disabled').text("Running...")

  $(".checkall").click (e) ->
    e.preventDefault()
    $(".flagcheck").click()
    $(e.target).addClass('disabled').text("Running...")

  $(".cancelall").click (e) ->
    e.preventDefault()
    $(".flagcancel").click()
    $(e.target).addClass('disabled').text("Running...")

setupTooltips = ->
  $(".flaghide").tooltip()
  $("i[rel=tooltip]").tooltip()

setupPhotoPopover = ->
  $("a.photopopover").popover(
    trigger: "hover"
    content: () -> "<img src='#{$(this).attr('href')}'>"
    html: true
    placement: (context, source) ->
      if (($(source).position().top - $(window).scrollTop())/$(window).height() > 0.5)
        'top'
      else
        'bottom'
  )

setupFilterButton = ->
  $(".include_types").on("change", (e) ->
    e.preventDefault()
    types = []
    $(".include_flag_type:checked").each( (i,e) -> types.push(e.value))

    updateUrlParams({'include_types': types.join(",")})
  )

@updateUrlParams = (newparams) ->
  clearTimeout(@timeoutId)
  q = queryString.parse(location.search);
  $.extend(q, newparams)
  @timeoutId = setTimeout((-> location.search = queryString.stringify(q)), 600)
