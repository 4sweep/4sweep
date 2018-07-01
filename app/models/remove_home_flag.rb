module Foursquare2
  module Venues
    def venue_edit(venue_id, options={})
      response = connection.post do |req|
        req.url "venues/#{venue_id}/edit", options
      end
      return_error_or_body(response, response.body.response)
    end
  end
end

# This class has been deprecated
class RemoveHomeFlag < Flag

  def submithelper
    venue = client.venue(venueId)
    catIds = venue.categories.map {|e| e.id}
    if (catIds.include?(HOME_CAT_ID))
      newCatIds = catIds.reject {|e| e == HOME_CAT_ID}
      client.venue_edit(venueId, :categoryId => newCatIds.join(","))
    else
      self.update_attribute("resolved_details", "does not have home cat")
      self.update_attribute("status", "resolved")
    end

  end

  def resolved?
    return true if status == 'resolved'
    venue = client.venue(venueId)
    catIds = venue.categories.map {|e| e.id}

    begin
      unless (catIds.include?(HOME_CAT_ID))
        self.update_attribute("status", "resolved")
        self.update_attribute('resolved_details', nil)
        return true
      end

      if primary_id_changed?(venue)
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(merged)') 
        return true
      end

      if is_home?(venue)
        self.update_attribute('status', 'alternate resolution')
        self.update_attribute('resolved_details', '(merged)') 
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

    false
  end

  def friendly_name
    "Remove Home Category"
  end
end
