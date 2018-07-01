class CloseFlag < Flag
  attr_accessible :problem
  validates_inclusion_of :problem, :in => %w( event_over closed ), :on => :create, :message => " problem %s is not allowed for CloseFlag"

  def submithelper
    client.flag_venue(venueId, :problem => problem, :comment => comment_text)
  end

  def resolved?
    return true if status == 'resolved'
    resolved = false
    begin
      venue = client.venue(venueId)
    rescue Foursquare2::APIError => e
      if e.message =~ /has been deleted/ or e.message =~ /is invalid for venue id/
        self.update_attribute('status', 'resolved')
        self.update_attribute('resolved_details', '(deleted)')
        self.update_attribute('last_checked', Time.now)
        return true
      else
        raise e
      end
    end

    resolved = is_closed?(venue)
    update_attribute('status', 'resolved') if resolved
    update_attribute('resolved_details', nil) if resolved

    if (!resolved)
      if primary_id_changed?(venue)
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(merged)')
        return true
      end

      if is_home?(venue)
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(home)')
        return true
      end

      self.update_attribute('last_checked', Time.now)
      # self.update_attribute('primaryHasHome', self.has_home?(venue))
    end

    resolved
  end

  def friendly_name
    "Close: " +
      case problem
        when "event_over"
          "Event Over"
        when "closed"
          "Closed"
      end
  end
end
