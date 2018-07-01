class CategoryChangeFlag < Flag
  attr_accessible :itemId, :itemName
  validates_presence_of :itemId, :on => :create, :message => "can't be blank"
  validates_presence_of :itemName, :on => :create, :message => "can't be blank"

  def getVenueOrResolve
    begin
      venue = client.venue(venueId)

      # if primary_id_changed?(venue)
      #   self.status = 'alternate resolution'
      #   self.resolved_details = '(merged)'
      #   save

      #   return true
      # end

      if is_closed?(venue)
        self.status = 'alternate resolution'
        self.resolved_details = '(closed)'
        self.save
        return true
      end

      return venue
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
  end

  def resolved?
    return true if status == 'resolved'
    return false if status == 'queued'

    resolved = false
    venue = getVenueOrResolve()
    if (venue === true)
      return true
    else
      resolved = category_resolved?(venue)
      self.status = 'resolved' if resolved
      self.resolved_details = nil if resolved
    end

    self.last_checked = Time.now
    self.save

    resolved
  end
end
