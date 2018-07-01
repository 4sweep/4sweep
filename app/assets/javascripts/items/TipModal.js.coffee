class TipModal extends ItemModal
  limit: 200
  template: "tips/tips"
  flagType: "TipFlag"
  constructor: (@source) ->
    super(@source, "tip")
  itemName: (tip) ->
    tip.text

window.TipModal = TipModal
