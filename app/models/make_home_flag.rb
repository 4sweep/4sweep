class MakeHomeFlag < ReplaceAllCategoriesFlag
  after_initialize :set_home_values

  def set_home_values
    self.itemName = "Home (Private)"
    self.itemId = HOME_CAT_ID
  end

  def submithelper
    if (user.level.empty? || user.level == "1")
      # SU <=1 seem to have bad behavior with the proposeEdit endpoint, so let's use home_recategorize flag
      client.flag_venue(venueId, :problem => 'home_recategorize', :comment => comment_text)
    else
      # We prefer to submit this through the /venue/edit endpoint, since it seems to work way better
      super
    end
  end

  def itemId
    HOME_CAT_ID
  end

  def itemName
    "Home (Private)"
  end

  def friendly_name
    "Category: Home"
  end
end
