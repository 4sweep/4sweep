class RequestLog < ActiveRecord::Base
  attr_accessible :request, :src, :user_id, :rate_limit, :limit_remaining
end