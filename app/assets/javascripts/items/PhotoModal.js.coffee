class PhotoModal extends ItemModal
  template: "photos/photos"
  flagType: "PhotoFlag"
  DEFAULT_SIZE: 'medium'
  photoTips: {}

  fetchTips: (offset = 0, retries = 3) ->
    tipModal = @tipModal()

    $.ajax
      dataType: 'json'
      url: tipModal.loadUrl()
      success: (data) =>
        tips = tipModal.getItems(data)
        @fetchTips(offset + tipModal.limit) if (tips.items.length > 2) # Kick off next page
        for tip in tips.items when tip.photo
          @photoTips[tip.photo.id] = tip
          @attachTip(tip)
      error: () =>
        if retries > 0
          @fetchTips(offset, --retries)
        else
          $.pnotify
            title: "Problem loading tips"
            width: '450px'
            text: "\nCould not load tips that may be associated with these photos."
            type: 'error'
            icon: false

      data:
        $.extend(tipModal.requestParams(), {offset: offset})

  attachTip: (tip) ->
    return unless tip.photo
    photoElem = @modal.find(".item_#{tip.photo.id}")
    return if photoElem.hasClass('hasTip')
    photoElem.addClass("hasTip").removeClass("noknowntip")
    photoElem.find(".tipholder").text(" [Has Associated Tip]").tooltip
      title: tip.text
    photoElem.find(".tipicon").tooltip
      title: tip.text

  processItems: (items) ->
    super(items)
    for item in items.items when @photoTips[item.id]
      @attachTip(@photoTips[item.id])

  photoOptions: (size) ->
    switch size
      when 'tiny'
        {size: size, span: "span1", text: "Tiny", request: "100x100", height: "100px", width: "100px"}
      when 'small'
        {size: size, span: "span2", text: "Small", request: "300x300", height: "200px", width: "200px"}
      when 'medium'
        {size: size, span: "span3", text: "Medium", request: "300x300", height: "300px", width: "300px"}
      when 'large'
        {size: size, span: 'span4', text: "Large", request: "500x500", height: "400px", width: "400px"}

  photoSize: () ->
    if Cookies.get("photosize") && Cookies.get("photosize") in ["tiny", "small", "medium", "large"]
      Cookies.get("photosize")
    else
      @DEFAULT_SIZE

  extraOptions: () ->
    $.extend(super(), size: @photoOptions(@photoSize()))

  getItems: (data) -> 
    data.response.photos

  constructor: (@source) ->
    super(@source, "photo")

  show: () ->
    super()
    @fetchTips()

    # Set up zoom icon for photos
    @modal.on("click", ".zoomicon", (e) =>
      e.preventDefault()
      photo = $(e.target).parents(".venuephoto").data("item")
      $("#photozoommodal").modal('show')
      $("#photozoommodal .modal-body").html(HandlebarsTemplates['photos/zoommodal']({photo: photo, tip: @photoTips[photo.id]}))
    )

    # Set up radio checkbox
    self = this
    @modal.find("input:radio[name=photosize][value='#{@photoSize()}']").prop("checked", true)

    @modal.find("input:radio[name=photosize]").change (e) ->
      Cookies.set("photosize", $(this).val())
      self.clearItems()
      self.loadMore()
      self.markAlreadyFlagged()

  itemName: (photo) ->
    photo.prefix + "SIZE" + photo.suffix

window.PhotoModal = PhotoModal
