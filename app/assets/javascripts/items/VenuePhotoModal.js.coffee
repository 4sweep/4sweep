class VenuePhotoModal extends PhotoModal
  sourceType: "venue"

  DEFAULT_GROUP: ""
  group: () ->
    if Cookies.get("photosort") && Cookies.get("photosort") in ["", "venue"]
      Cookies.get("photosort")
    else
      @DEFAULT_GROUP

  photoSort: () ->
    @modal.find(".photosort").val() || @DEFAULT_GROUP

  constructor: (@source) ->
    super(@source)

  tipModal: () ->
    @tipModalCache ||= new VenueTipModal(@source)

  show: () ->
    super()

    self = this
    @modal.find(".sort-holder").html(HandlebarsTemplates['photos/sort']())

    @modal.find(".photosort").val(@group())

    @modal.find(".photosort").change (e) ->
      Cookies.set("photosort", $(this).val())
      self.clearItems()
      self.loadMore()

  loadUrl: () -> "https://api.foursquare.com/v2/venues/#{@source.id}/photos"

  requestParams: () ->
    $.extend(super(), {group: @group()})

window.VenuePhotoModal = VenuePhotoModal
