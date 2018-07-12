class ExplorerController < ApplicationController
  before_filter :require_user

  def explore
    @categories = CategoriesCache::latest.categories
    @flagcount = Flag.find_all_by_user_id_and_status(@current_user, ['new', 'queued']).count()
    @lat, @lng = @current_user.recent_ll
    @lat ||= 40.664167
    @lng ||= -73.938611
    @client_id = Settings.app_id
    @google_maps_key = Settings.google_maps_key
  end
end

