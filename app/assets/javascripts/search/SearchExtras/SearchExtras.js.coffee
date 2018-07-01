class SearchExtras
  render: (extrasDiv) ->

window.SearchExtras = SearchExtras

class ListSearchExtras extends SearchExtras
  constructor: (@listResponse) ->

  render: (extrasDiv) ->
    extrasDiv.html(HandlebarsTemplates['search_extras/listextras'](@listResponse))
window.ListSearchExtras = ListSearchExtras

