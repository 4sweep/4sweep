class UncategorizedQueueSearch extends QueueSearch
  supportsLoadMore: false
  searchTab: 'uncategorizedsearch'

  constructor: (@location = new GlobalLocation(), @options = {}) ->
    super('uncategorized', @location)

  serialize: () ->
    $.extend @location.serialize(),
      s: @searchTab

  @deserialize: (values) ->
    new UncategorizedQueueSearch SearchLocation.deserialize values
window.UncategorizedQueueSearch = UncategorizedQueueSearch
