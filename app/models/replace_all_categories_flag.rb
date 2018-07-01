class ReplaceAllCategoriesFlag < CategoryChangeFlag

  def submithelper
    venue = getVenueOrResolve()
    if (venue === true)
      return
    end
    if (category_resolved?(venue))
      self.update_attribute("status", "resolved")
      return true
    end
    removeCategoryIds = venue.categories.map {|e| e.id}.reject{|e| e == itemId}.join(",")
    params = {
      :primaryCategoryId => itemId,
      :comment => comment_text
    }
    if removeCategoryIds.size > 0
      params['removeCategoryIds'] = removeCategoryIds
    end

    client.propose_venue_edit(venueId, params)
  end

  def category_resolved?(venue)
    (venue.categories.map {|e| e.id}.include?(itemId)) && (venue.categories.size == 1)
  end

  def friendly_name
    "Set Category To: " + itemName
  end
end
