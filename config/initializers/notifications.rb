# ActiveSupport::Notifications.subscribe('request.faraday') do |name, starts, ends, _, env|
#   url = env[:url]
#   http_method = env[:method].to_s.upcase
#   duration = ends - starts
#   Rails.logger.info "  API REQUEST TO: #{url.host}, #{http_method}, #{url.request_uri}, takes #{duration} seconds, rate-limit: #{env[:response_headers]['x-ratelimit-limit']}, rate-limit-remaining: #{env[:response_headers]['x-ratelimit-remaining']}, status: #{env[:status]}"
# end
