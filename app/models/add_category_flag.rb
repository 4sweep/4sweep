class AddCategoryFlag < CategoryChangeFlag

  def submithelper
    client.propose_venue_edit(venueId, :addCategoryIds => itemId, :comment => comment_text)
  end

  def category_resolved?(venue)
    (venue.categories.map {|e| e.id}.include?(itemId))
  end

  def friendly_name
    "Add Category: " + itemName
  end
end
