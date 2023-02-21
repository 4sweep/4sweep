class VenueTipModal extends TipModal
  sourceType: "venue"

  DEFAULT_SORT: "popular"

  order: () ->
    if Cookies.get("tipsort") && Cookies.get("tipsort") in ["popular", "recent"]
      Cookies.get("tipsort")
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
      Cookies.set("tipsort", $(this).val())
      self.clearItems()
      self.loadMore()

  requestParams: () ->
    $.extend(super(), {sort: @order()})

window.VenueTipModal = VenueTipModal
