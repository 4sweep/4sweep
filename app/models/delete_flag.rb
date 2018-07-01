class DeleteFlag < Flag
  attr_accessible :problem

  validates_inclusion_of :problem, :in => %w( mislocated inappropriate closed doesnt_exist event_over ), :on => :create, :message => "value %s is not valid for DeleteFlag"

  def submithelper
    client.flag_venue(venueId, :problem => problem, :comment => comment_text)
  end

  def resolved?
    return true if status == 'resolved'
    resolved = false

    begin
      venue = client.venue(venueId)
      # self.update_attribute('primaryHasHome', has_home?(venue))


      if is_home?(venue)
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(home)')
        return true
      end

      if is_closed?(venue)
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(closed)')
        return true
      end

      if primary_id_changed?(venue)
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(merged)')
        return true
      end

      if venue.deleted == true
        self.update_attribute('status', 'resolved')
        self.update_attribute('resolved_details', nil)
        self.update_attribute('last_checked', Time.now)
      end
    rescue Foursquare2::APIError => e
      if e.message =~ /has been deleted/ or e.message =~ /is invalid for venue id/
        resolved = true
        self.update_attribute('status', 'resolved')
        self.update_attribute('resolved_details', nil)
        self.update_attribute('last_checked', Time.now)
      else
        raise e
      end
    end
    self.update_attribute('last_checked', Time.now)

    resolved
  end

  def friendly_name
    "Remove: " +
      case problem
        when "doesnt_exist"
          "Doesn't Exist"
        when "inappropriate"
          "Inappropriate"
      end
  end
end
