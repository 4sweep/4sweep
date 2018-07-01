#= require search/Pagination/Pagination
class KnownSizePagination extends Pagination
  template: 'explore/known_size_pagination'

  constructor: (options) ->
    @current = options.currentPage
    @pageSize = options.pageSize
    @totalItems = options.totalItems

    @totalPages = Math.ceil @totalItems/@pageSize
    @searchAtPage = options.searchAtPage

    @onLastPage = @current == @totalPages

    @showpages = for i in [1..@totalPages]
      pagenum: i
      active: i == @current
      classes: if i == @current then "active" else ""
      show: Math.abs(@current - i) < 5

window.KnownSizePagination = KnownSizePagination
