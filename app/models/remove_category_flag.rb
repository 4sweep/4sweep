class RemoveCategoryFlag < CategoryChangeFlag

  def submithelper
    client.propose_venue_edit(venueId, :removeCategoryIds => itemId, :comment => comment_text)
  end

  def category_resolved?(venue)
    !(venue.categories.map {|e| e.id}.include?(itemId))
  end

  def friendly_name
    "Remove Category: " + itemName
  end
end
