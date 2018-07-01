class MakePrivateFlag < Flag
  attr_accessible :problem

  validates_inclusion_of :problem, :in => %w( private ), :on => :create, :message => "problem cannot be %s"

  def submithelper
    client.flag_venue(venueId, :problem => problem, :comment => comment_text);
  end

  def resolved?
    return true if status == 'resolved'
    resolved = false

    begin
      venue = client.venue(venueId)

      if primary_id_changed?(venue)
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(merged)')
        return true
      end

      if is_closed?(venue)
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(closed)')
        return true
      end

      if is_home?(venue)
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(home)')
        return true
      end

      if venue['private'] == true
        self.update_attribute('status', 'resolved')
        self.update_attribute('resolved_details', nil)
        return true
      end
    rescue Foursquare2::APIError => e
      if e.message =~ /has been deleted/ or e.message =~ /is invalid for venue id/
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(deleted)')
        return true
      else
        raise e
      end

    end
    self.update_attribute('last_checked', Time.now)
    resolved
  end

  def friendly_name
    "Make Private"
  end

end
