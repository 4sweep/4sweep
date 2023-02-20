class ExplorerController < ApplicationController
  before_action :require_user

  def explore
    @categories = CategoriesCache::latest.categories
    @flagcount = Flag.where(user_id: @current_user, status: ['new', 'queued']).count()
    @lat, @lng = @current_user.recent_ll
    @lat ||= 40.664167
    @lng ||= -73.938611
    @client_id = Settings.app_id
    @google_maps_key = Settings.google_maps_key
  end
end

