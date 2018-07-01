# Hack alert: We need to add flag_tip to Foursquare2 for this
module Foursquare2
  module Tips
    # Flag a photo as having a problem
    #
    # @param [String] tip_id - Tip id to flag, required.
    # @param [Hash] options
    # @option options String :problem - Reason for flag, one of 'nolongerrelevant', 'spam', 'offensive'
    def flag_tip(tip_id, options={})
      response = connection.post do |req|
        req.url "tips/#{tip_id}/flag", options
      end
      return_error_or_body(response, response.body.response)
    end

  end
end

class TipFlag < Flag
  attr_accessible :itemId, :itemName, :creatorId, :creatorName
  validates_presence_of :itemId, :on => :create, :message => "can't be blank"
  validates_inclusion_of :problem, :in => ['nolongerrelevant', 'spam', 'offensive'],
                         :on => :create, :message =>  "problem %s is not valid for tips"

  def submithelper
    begin
      result = client.flag_tip(itemId, :problem => problem, :comment => comment)
    rescue Foursquare2::APIError => e
      if e.message =~ /Must provide a valid Tip ID/ or e.message =~ /Tip ID not found/
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
      tip = client.tip(itemId)
      if (tip.flags and tip.flags.include?("no_longer_relevant"))
        resolved=true
        self.status = 'resolved'
        self.resolved_details = nil
      end
    rescue Foursquare2::APIError => e
      if e.message =~ /Must provide a valid Tip ID/ or e.message =~ /Tip ID not found/
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
    "Tip: " +
    case problem
    when 'nolongerrelevant'
      "No Longer Relevant"
    when "offensive"
      "Offensive"
    when "spam"
      "Spam"
    end
  end
end
