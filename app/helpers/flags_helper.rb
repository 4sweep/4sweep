module FlagsHelper

  def friendly_status(status)
    case status
      when 'not_authorized'
        'not authorized'
      when 'new'
        'not yet submitted'
      when 'resolved'
        'accepted'
      else
        status
    end
  end
end
