class MergeFlag < Flag
  attr_accessible :secondaryJSON, :secondaryName, :secondaryVenueId

  def submithelper
    client.flag_venue(venueId, :problem => 'duplicate', :venueId => secondaryVenueId, :comment => comment_text)
  end

  def self.from_venues(venue1, venue2)
  end

  def resolved?
    return true if status == 'resolved'

    begin
      primary = client.venue(venueId)
      secondary = client.venue(secondaryVenueId)
    rescue Foursquare2::APIError => e
      if e.message =~ /has been deleted/ or e.message =~ /is invalid for venue id/
        self.status = 'alternate resolution'
        self.resolved_details = '(deleted)'
        self.save
        return true
      else
        raise e
      end
    end
    self.update_attribute('last_checked', Time.now)

    if primary.id == secondary.id
      self.status = 'resolved'
      self.resolved_details = nil
      self.save
      return true
    end

    if primary.id != venueId  or secondary.id != secondaryVenueId
      self.status = 'alternate resolution'
      self.resolved_details = '(merged with another venue)'
      self.save
      return true
    end

    if is_home?(primary) or is_home?(secondary)
      self.status = 'alternate resolution'
      self.resolved_details = '(home)'
      self.save
    end

    if is_closed?(primary) or is_closed?(secondary)
      self.status = 'alternate resolution'
      self.resolved_details = '(closed)'
      self.save
      return true
    end

    false
  end

  def friendly_name
    "Duplicate"
  end
end
