class window.PageVenuesSearchTab extends SearchManagerTab
  displayControls: ['global', 'box', 'circle', 'polygon', 'near']
  setLocationTypeOnShown: 'global'

  createSearch: (location = @locationManager.location()) ->
    options = {loadMoreContainer: @tab.find(".loadmorecontainer")}
    if (@tab.find(".pagesearch-type").val() == 'id')
      return new PageVenuesSearch(@tab.find('.pagesearch-value').val(), location, 1, options)
    else
      @performPageSearch(@tab.find(".pagesearch-type").val(), @tab.find(".pagesearch-value").val(), location, options)
      return false

  performPageSearch: (searchType, searchText, location, options) ->
    # We perform a search of the given type.  If it returns one value, we perform a search on that value.
    # Otherwise, we display a modal with the search results
    val = {}
    val[searchType] = searchText
    if searchText.trim() == ""
      return

    $.ajax
      url: "https://api.foursquare.com/v2/users/search"
      dataType: "json"
      data: $.extend val,
        oauth_token: token
        v: API_VERSION
        m: 'swarm'
        limit: 200
      success: (data) =>
        if data.response.results.length == 1
          @explorer.performSearch(new PageVenuesSearch(data.response.results[0].id, location, 1, options))
        else
          @displaySearchResultsModal(data.response.results, searchType, searchText, location, options)
      error: (xhr, textStatus, errorThrown) =>
        alert("A search error has occurred.  Please check your input and try again.")

  displaySearchResultsModal: (results, searchType, searchText, location, options) ->
    modalparent = $('.attach-modal').html HandlebarsTemplates['explore/pagesearch_results']
      results: results.filter((e) -> e.type == 'chain').sort( (a, b) -> b.followers?.count - a.followers?.count )

    modal = $(modalparent).children("#pagepicker")
    $(modal).find(".selectpage").click (e) =>
      e.preventDefault()
      id = $(e.target).data('pageid')
      @explorer.performSearch(new PageVenuesSearch(id, location, 1, options))
      $(modal).modal('hide')
    $(modal).modal('show')
