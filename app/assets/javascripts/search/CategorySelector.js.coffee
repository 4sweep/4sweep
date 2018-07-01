class CategorySelector

  subCategoriesData: (cats, level = 1, upId) ->
    result = []
    prevId = upId
    for cat in cats
      result.push
        id: cat.id
        text: cat.name
        level: level
        hasChildren: cat.categories?.length > 0
        prevId: prevId
        upId: upId
      if cat.categories
        result = result.concat(@subCategoriesData(cat.categories, level + 1, cat.id))
      prevId = cat.id
    result

  setupCategoryData: () ->
    result = @subCategoriesData(categories)
    for cat, i in result
      continue if i == 0
      result[i-1].nextId = cat.id
    result

  # options:
  #   'allowMultiple'
  #   'recentChoicesSelector'
  #   'rotateButtonsSpanSelector'
  setupCategories: (selector, options = {}) ->
    CategorySelector.categoryData ||= @setupCategoryData()
    selector.select2
      data: CategorySelector.categoryData
      multiple: options.allowMultiple == true
      formatResultCssClass: (object) ->
        'category-indent-' + object.level + " " + if object.hasChildren then " optionbold" else ""

    @setupRecentChoices(selector, options.recentChoicesSelector) if options.recentChoicesSelector?
    @setupRotateButtons(selector, options.rotateButtonsSpanSelector) if options.rotateButtonsSpanSelector?

  setupRecentChoices: (selector, recentChoicesSelector) ->
    recentlyused = JSON.parse($.cookie("recentlyused")) || []
    if recentlyused.length > 0
      $(selector).select2('val', recentlyused[0]['cat_id'])
      @showRecentlyUsed(recentlyused, recentChoicesSelector)

    $(selector).change (e) =>
      cat_id = $(e.target).select2('val')
      cat_name = $(e.target).select2('data').text

      recentlyused = JSON.parse($.cookie("recentlyused")) || []
      return if (recentlyused.length > 0 && recentlyused[0]['cat_id'] == cat_id)

      recentlyused = $.grep recentlyused, ((e, i) -> e['cat_id'] == cat_id), true
      recentlyused.unshift({cat_id: cat_id, name: cat_name})
      recentlyused = recentlyused[0..6]
      $.cookie('recentlyused', JSON.stringify(recentlyused))
      @showRecentlyUsed(recentlyused, recentChoicesSelector)

    $(recentChoicesSelector).on "click", ".chooserecentcat", (e) =>
      e.preventDefault()
      $(selector).select2('val', $(e.target).data('catid')).trigger('change')

  setupRotateButtons: (selector, rotateButtonsSpanSelector) ->
    rotateButtonsSpanSelector.find(".catrotate").click (e) ->
      e.preventDefault()
      field = $(this).data('rotate') + "Id"
      data = selector.select2('data')[0]
      if data?[field]
        selector.select2('val', [data[field]])
      true

  showRecentlyUsed: (recentlyused, recentChoicesSelector) ->
    $(recentChoicesSelector).html(HandlebarsTemplates['explore/recently_used_categories'](recent: recentlyused[1..5]))

window.CategorySelector = CategorySelector
