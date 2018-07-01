class UserPhotoModal extends PhotoModal
  sourceType: "user"
  loadUrl: () -> "https://api.foursquare.com/v2/users/#{@source.id}/photos"
  tipModal: () ->
    @tipModalCache ||= new UserTipModal(@source)

window.UserPhotoModal = UserPhotoModal
