class DuplicateSearchTab extends SearchManagerTab
  displayControls: ['circle', 'box', 'polygon', 'near']
  setLocationTypeOnShown: 'circle'

  createSearch: (overrideLocation) ->
    locations = @tab.find(".locations").val()
    page = @tab.find(".currentPage").val() || 1
    query = @tab.find(".query").val()
    radius = @tab.find(".radius").val()
    @locationManager.radiusControl?.addTempRadius(radius)
    new DuplicateVenuesSearch(locations, page, query, radius, overrideLocation)

  setupEvents: () ->
    super()
    @tab.find('.locations').change (e) =>
      locs = @locations()
      currentLoc = @tab.find(".currentPage").val()
      @tab.find(".locationsCount").val(currentLoc + " of " + locs.length)

    @tab.find(".dupsearchhelp").click (e) =>
      e.preventDefault()
      @showHelpModal()

    @tab.find('.editLocations').click (e) =>
      e.preventDefault()
      @showLocationsEditor()

  showHelpModal: () ->
    modalparent = $('.attach-modal').html HandlebarsTemplates['explore/dupsearch_help']()
    modal = $(modalparent).children("#dupsearch-help")
    $(modal).modal('show')

  showLocationsEditor: () ->
    modalparent = $('.attach-modal').html HandlebarsTemplates['explore/locationseditor']
      locations: @locations()
    modal = $(modalparent).children("#locationseditor")
    modal.find(".setlocations").click (e) =>
      e.preventDefault()

      try
        locations = DuplicateVenuesSearch.locationsFromString(modal.find("#locationsbox").val())
        @tab.find(".currentPage").val(1)
        @tab.find(".locations").val(locations.join(";")).trigger("change")
        $(modal).modal('hide')
        @tab.find(".defaultsearch").click()

      catch e
        throw e unless e.name == "SyntaxError"
        modal.find("#locationsbox").parents(".control-group").addClass("error")
        modal.find(".alert.locationlisterror").removeClass('hide')

    $(modal).modal('show')

  locations: () ->
    DuplicateVenuesSearch.locationsFromString(@tab.find('.locations').val())

  displaySearch: (search) ->
    super(search)
    @tab.find('.locations').trigger('change')

  updateSearch: (search) ->
    @displaySearch(search)

window.DuplicateSearchTab = DuplicateSearchTab
