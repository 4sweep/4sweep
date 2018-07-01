class UserTipModal extends TipModal
  sourceType: "user"
  loadUrl: () -> "https://api.foursquare.com/v2/lists/#{@source.id}/tips"

  searchText: (tipdata) ->
    tipdata.text + " " + (tipdata.venue.name)

  getItems: (data) ->
    items:
      data.response.list.listItems.items.map (e) ->
        result = $.extend(e.tip, {venue: e.venue})
        if e.photo
          result = $.extend(result, {photo: e.photo})
        result

window.UserTipModal = UserTipModal
