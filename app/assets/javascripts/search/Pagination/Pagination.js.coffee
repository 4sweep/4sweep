class Pagination
  render: (performSearchFunction) ->
    result = $(HandlebarsTemplates[@template](this))
    result.on "click", "li", (e) =>
      e.preventDefault()
      return if $(e.target).parent().hasClass('disabled') or $(e.target).parent().hasClass('active')
      performSearchFunction(@searchAtPage($(e.target).data('pagenum')))
    result

window.Pagination = Pagination
