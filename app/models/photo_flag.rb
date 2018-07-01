# Hack alert: We need to add flag_photo to Foursquare2 for this
module Foursquare2
  module Photos
    # Flag a photo as having a problem
    #
    # @param [String] photo_id - Photo id to flag, required.
    # @param [Hash] options
    # @option options String :problem - Reason for flag, one of 'spam_scam', 'nudity', 'hate_violence', 'illegal', 'unrelated', 'blurry'. Required.
    def flag_photo(photo_id, options={})
      response = connection.post do |req|
        req.url "photos/#{photo_id}/flag", options
      end
      return_error_or_body(response, response.body.response)
    end

  end
end

class PhotoFlag < Flag
  attr_accessible :itemId, :itemName, :creatorId, :creatorName
  validates_presence_of :itemId, :on => :create, :message => "can't be blank"
  validates_inclusion_of :problem, :in => ['spam_scam', 'nudity', 'hate_violence', 'illegal', 'unrelated', 'blurry'],
                         :on => :create, :message =>  "problem %s is not valid for Photos"

  def submithelper
    begin
      result = client.flag_photo(itemId, :problem => problem, :comment => comment)
    rescue Foursquare2::APIError => e
      if e.message =~ /not authorized to view/ or e.message =~ /Must provide a valid photo ID/
        self.status = 'resolved'
        self.resolved_details = nil
        save
      else
        raise e
      end
    end
    result
  end

  def resolved?
    return true if status == 'resolved'
    resolved = false

    begin
      photo = client.photo(itemId)
      if photo.demoted == true
        resolved = true
        self.status = 'resolved'
        self.resolved_details = nil
      end
      if photo.venue.nil?
        self.status = "alternate resolution"
        self.resolved_details = "(venue gone)"
        resolved = true
      else
        if photo.venue.categories[0] && photo.venue.categories[0].id == HOME_CAT_ID
          self.status = "alternate resolution"
          self.resolved_details = "(venue is home)"
          resolved = true
        end
        if photo.venue.closed
          self.status = "alternate resolution"
          self.resolved_details = "(venue closed)"
          resolved = true
        end
      end
    rescue Foursquare2::APIError => e
      if e.message =~ /not authorized to view/ or e.message =~ /Must provide a valid photo ID/
        resolved = true
        self.status = 'resolved'
        self.resolved_details = nil
      else
        raise e
      end
    end

    self.last_checked = Time.now
    save
    resolved
  end

  def friendly_name
    "Photo: " +
     case problem
     when "spam_scam"
       "Spam"
     when "nudity"
       "Nudity"
     when "hate_violence"
       "Hate/Violence"
     when "illegal"
       "Illegal"
     when "blurry"
       "Blurry"
     when "unrelated"
       "Unrelated"
     end
  end
end
