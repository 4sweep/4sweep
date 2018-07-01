class MakePrimaryCategoryFlag < CategoryChangeFlag

  def submithelper
    client.propose_venue_edit(venueId, :primaryCategoryId => itemId, :comment => comment_text)
  end

  def category_resolved?(venue)
    (venue.categories.select{|e| e.primary}.map {|e| e.id}.include?(itemId))
  end

  def friendly_name
    "Make Primary Category: " + itemName
  end
end
