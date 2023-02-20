class FilterContainer
  EMPTY_FILTER =
    field: "any"
    type: "text"
    arity: 2
    values: []
    operator:
      operator: "contains"
      opposite: "notcontains"

  constructor: (filterselector, @filters = []) ->
    @container = $(filterselector)
    @listeners = new Listeners(['filtersChanged'])
    @setup()

  setup: () ->
    # First, set up the show/hide buttons on the filterdiv
    @container.find(".showfilter").click (e) =>
      e.preventDefault()
      @showFilter()

    @container.find('.hidefilter').click (e) =>
      e.preventDefault()
      @hideFilter()

    @showFilter() if Cookies.get("showfilter") == 'true'

    @container.find(".filtererror").tooltip
      trigger: "manual"
      title: "Filter cannot be parsed"
      placement: "bottom"

    @setupFilterEditor()

    $(".hidefilter").tooltip()

    $(".filter-help").popover
      html: true
      title: "About Filters"
      placement: "bottom"
      trigger: "hover"
      container: ".attach-popover"
      template: '<div class="popover ontop superwide"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>',
      content: HandlebarsTemplates['filters/about_filters']()

    # Don't submit anything on enter
    @container.find(".filter").keydown (e) ->
      if e.keyCode == 13
        e.preventDefault()
        false

    @container.find(".filterrow input").keyup (e) =>
      e.preventDefault()
      try
        @filters = advancedsearch.parse(@container.find(".filter").val().trim())
        @container.find(".filterrow.control-group").removeClass("error")
        @container.find(".filtererror").tooltip("hide")
        @filtererrorshown = false
        @listeners.notify "filtersChanged", @filters
        @updateFilterRows()
      catch error
        if error.name == "SyntaxError"
          @container.find(".filterrow.control-group").addClass("error")
          @container.find(".filtererror").tooltip("show") unless @filtererrorshown
          @filtererrorshown = true
        else
          throw error

  showFilter: (val) ->
    @container.find(".filterlink").hide()
    @container.find(".filterform").show()
    Cookies.set("showfilter", "true")
    if val
      @container.find("input.filter").val(val)
      @container.find("input.filter").keyup()

  hideFilter: () ->
    @container.find("input.filter").val("")
    @container.find("input.filter").keyup()
    @container.find(".filterlink").show()
    @container.find(".filterform").hide()
    Cookies.set("showfilter", "false")

  setupFilterEditor: () ->
    filter = @container.find(".filter")
    filter.popover
      html: true,
      trigger: "manual",
      placement: 'bottom',
      title: "Edit Filter <button class='filteredit-popover-close close pull-right'>&times;</button>",
      content: () =>
        HandlebarsTemplates['filters/edit_filters']({filters: @filters})
      container: ".filterpopovercontainer",
      template: '<div class="popover superwide"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>',

    @container.find(".editfilter").click (e) =>
      e.preventDefault()
      filter.popover("toggle")

    filter.on "shown", (e) =>
      $(".open-popover").not(e.target).popover('hide').removeClass("open-popover")
      filter.addClass('open-popover')
      @popover = $(e.target).data('popover').tip()
      popover = @popover

      @updateFilterRows()

      popover.find(".filteredit-popover-close").click (e) =>
        e.preventDefault()
        filter.popover('hide')
      popover.find(".addrow").click (e) =>
        e.preventDefault()
        popover.find(".addfilter").append(@filterRow(EMPTY_FILTER))
      popover.find(".setfilter").click (e) =>
        e.preventDefault()
        @setFilterFromInputs()

    filter.on "hidden", (e) =>
      filter.removeClass("open-popover")
      @popover = undefined

  updateFilterRows: () ->
    @popover?.find(".addfilter").children().remove()
    if @filters.length == 0
      @popover?.find(".addfilter").append(@filterRow(EMPTY_FILTER))
    for filterobj in @filters
      @popover?.find(".addfilter").append(@filterRow(filterobj))

  filterRow: (filter) ->
    resolveNegated = (expression) ->
      result = $.extend {}, expression.target #clone
      result.operator = {operator: expression.target.operator.opposite}
      result.predicate = (venue) -> !(expression.target.predicate)
      return result

    if filter.type == 'negated'
      filter = resolveNegated(filter)

    filterrow = $(HandlebarsTemplates['filters/filterrow']({filter: filter}))
    filterrow.find('.fieldsselect').val(filter.field)
    filterrow.find('.opselect').val(filter.operator.operator)

    if filter.arity == 2
      switch filter.type
        when 'numeric'
          filterrow.find(".numericinput input").val(filter.value)
        when 'text'
          filterrow.find(".textinput input").val(filter.values?.map(@escapeString).join(','))
        when 'duration'
          filterrow.find(".durationinput input").val(filter.value.count)
          filterrow.find('.durationinput select').val(filter.value.unit)

    filterrow.on "change", ".fieldsselect", (e) =>
      fieldtype = filterrow.find('.fieldsselect option:selected').data('type')
      filterrow.find(".operatorposition").html(Handlebars.partials["filters/_operatorselect"]({type: fieldtype}))
      filterrow.find(".opselect").trigger('change')
      if $(e.target).find("option:selected").data('operandplaceholder')
        filterrow.find(".operand").attr('placeholder', $(e.target).find("option:selected").data('operandplaceholder'))

    filterrow.on "change", ".opselect", (e) =>
      fieldtype = filterrow.find('.fieldsselect option:selected').data('type')
      arity = filterrow.find(".opselect option:selected").data('arity')
      filterrow.find(".operandposition").html(Handlebars.partials["filters/_operand"]({type: fieldtype, arity: arity}))

    filterrow.on "change", ".operand", (e) => @setFilterFromInputs()

    filterrow.find(".btn.remove").click (e) =>
      filterrow.remove()
      @setFilterFromInputs()
    filterrow

  escapeString: (s) ->
    result = s.replace(/\//g, "\\\\").replace(/"/g, "\\\"")
    "\"#{result}\""

  setFilterFromInputs: () ->
    failed = false
    results = []
    @popover?.find(".filterlist .filterrow").each (i, filterrow) =>
      result = ""
      field = $(filterrow).find(".fieldsselect")
      op = $(filterrow).find(".opselect")
      $(filterrow).removeClass("error")

      if ($(filterrow).find("option:selected").hasClass("negated"))
        result += "-"

      result += field.val()
      result += op.find("option:selected").data('optext')
      if (op.find("option:selected").data('arity') == 2)
        operand =  $(filterrow).find('.operand')

        operandType = field.find("option:selected").data('type')
        try
          operandval = switch (operandType)
            when "numeric"
              advancedsearch.parse(operand.val(), {startRule: 'integer'})
            when "duration"
              advancedsearch.parse(operand.val() + " " + $(filterrow).find('.durationinput .durationtype').val() + "s", {startRule: 'duration'}).text
            when "text"
              @textParse(operand.val())
          result += operandval
        catch error
          if error.name == "SyntaxError"
            $(filterrow).addClass("error")
            failed = true
          else
            throw error
      results.push(result)

    unless failed
      @container.find(".filter").val(results.join(" AND ")).trigger("keyup")

  textParse: (text = "") ->
    try
      result = advancedsearch.parse(text, {startRule: 'textval'}).map(@escapeString).join(",")
    catch error
      if error.name == "SyntaxError"
        result = advancedsearch.parse(text, {startRule: 'catchall'}).map(@escapeString).join(",")
      else
        throw error
    result

  serialize: () ->
    filter: @container.find("input.filter")?.val() || ""

window.FilterContainer = FilterContainer
