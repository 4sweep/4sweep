class VenueTipModal extends TipModal
  sourceType: "venue"

  DEFAULT_SORT: "popular"

  order: () ->
    if $.cookie("tipsort") && $.cookie("tipsort") in ["popular", "recent"]
      $.cookie("tipsort")
    else
      @DEFAULT_SORT

  loadUrl: () -> "https://api.foursquare.com/v2/venues/#{@source.id}/tips"

  getItems: (data) -> data.response.tips

  searchText: (tipdata) ->
    tipdata.text + " " + (tipdata.user.firstName || " ") + " " + (tipdata.user.lastName || "")

  constructor: (@source) ->
    super(@source)

  show: () ->
    super()

    self = this
    @modal.find(".sortholder").html(HandlebarsTemplates['tips/sort']())

    @modal.find(".tipsort").val(@order())

    @modal.find(".tipsort").change (e) ->
      $.cookie("tipsort", $(this).val())
      self.clearItems()
      self.loadMore()

  requestParams: () ->
    $.extend(super(), {sort: @order()})

window.VenueTipModal = VenueTipModal
