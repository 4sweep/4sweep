#= require search/Pagination/Pagination
class UnknownSizePagination extends Pagination
  template: 'explore/unknown_size_pagination'

  constructor: (options) ->
    @current = options.currentPage
    @pageSize = options.pageSize
    @searchAtPage = options.searchAtPage
    @onLastPage = options.onLastPage
    @displayPagination = @current > 1 || !@onLastPage
    @prevPage = if @current > 1 then @current-1 else 1
    @nextPage = @current + 1

window.UnknownSizePagination = UnknownSizePagination
