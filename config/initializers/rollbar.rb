require 'rollbar/rails'

Rollbar.configure do |config|
  config.enabled = false
  config.access_token = 'REPLACE_ME'
  config.exception_level_filters.merge!('ActionController::RoutingError' => 'ignore')
  config.dj_threshold = 5

  if Rails.env.development?
    config.enabled = false
  end
end
