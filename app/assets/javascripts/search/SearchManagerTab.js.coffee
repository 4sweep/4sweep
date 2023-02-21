class SearchManagerTab
  constructor: (@tab, @explorer, @locationManager) ->

  toggles: () ->
    $("a[href=\"\##{@tab.attr('id')}\"][data-toggle='tab']")

  shown: () ->
    @locationManager.setActiveTab(this)
    @locationManager.showControls(@displayControls)
    if @setLocationTypeOnShown == 'global'
      @locationManager.setGlobal()

  performSearchAt: (location) ->
    search = @createSearch(location)
    @explorer.performSearch(search)
    search

  displaySearch: (search) ->
    for own key, val of search
      toset = @tab.find("[data-deserialize=#{key}]")
      if toset.hasClass('select2')
        toset.select2('val', val)
      else
        toset.val(val)
    @toggles().tab('show')

    @locationManager.displaySearchLocation(search)

  updateSearch: (search) ->

  setupEvents: () ->
    @tab.find(".defaultsearch").click (e) =>
      e.preventDefault()
      search = @createSearch()
      @explorer.performSearch(search) if search
    @toggles().on('shown', (e) => @shown(e))
window.SearchManagerTab = SearchManagerTab

class PrimaryVenueSearchTab extends SearchManagerTab
  displayControls: ['near', 'box', 'circle', 'polygon']

  setupEvents: () ->
    new CategorySelector().setupCategories @tab.find("select.categories"),
      allowMultiple: true
      rotateButtonsSpanSelector: @tab.find(".catRotateButtons")
    super()

  createSearch: (location = @locationManager.location(true)) ->
    new PrimaryVenueSearch(@tab.find(".query").val(), location, @tab.find("select.categories").select2('data').map((x) -> x.id), {loadMoreContainer: @tab.find(".loadmorecontainer")})
window.PrimaryVenueSearchTab = PrimaryVenueSearchTab

class GlobalSearchTab extends SearchManagerTab
  displayControls: ['global']
  setLocationTypeOnShown: 'global'
  createSearch: () ->
    new GlobalVenueSearch(@tab.find(".query").val(), @tab.find(".categories").select2('data').map((x) -> x.id))
  setupEvents: () ->
    new CategorySelector().setupCategories @tab.find("select.categories"),
      allowMultiple: true
      rotateButtonsSpanSelector: @tab.find(".catRotateButtons")
    super()
window.GlobalSearchTab = GlobalSearchTab

class UserSearchTab extends SearchManagerTab
  displayControls: ['global']
  setLocationTypeOnShown: 'global'
  createSearch: () ->
    switch @tab.find(".usersearch-type").val()
      when 'venuescreated'
        new UserCreatedVenueSearch(@tab.find(".userid").val(), 1, {loadMoreContainer: @tab.find(".loadmorecontainer")})
      when 'venuesliked'
        new UserVenueLikesSearch(@tab.find(".userid").val(), 1, {loadMoreContainer: @tab.find(".loadmorecontainer")})
      when 'venuesphotoed'
        new UserPhotoVenueSearch(@tab.find(".userid").val(), 1, {loadMoreContainer: @tab.find(".loadmorecontainer")})
      when 'venuestipped'
        new UserTipVenueSearch(@tab.find(".userid").val(), 1, {loadMoreContainer: @tab.find(".loadmorecontainer")})
      else
        throw "Unknown User search type"

window.UserSearchTab = UserSearchTab

class SpecificVenueSearchTab extends SearchManagerTab
  displayControls: ['global']
  setLocationTypeOnShown: 'global'
  createSearch: () ->
    switch @tab.find(".specificvenuessearch-type").val()
      when 'specificvenue'
        new SpecificVenueSearch(@tab.find(".venueid").val())
      when 'venuechildren'
        new VenueChildrenSearch(@tab.find(".venueid").val())
      else
        throw "Unknown Specific Venue Search Type"

window.SpecificVenueSearchTab = SpecificVenueSearchTab

class UncategorizedVenuesSearchTab extends SearchManagerTab
  displayControls: ['global', 'near', 'box', 'circle', 'polygon']
  createSearch: (location = @locationManager.location()) ->
    new UncategorizedQueueSearch(location, {loadMoreContainer: @tab.find(".loadmorecontainer")})
window.UncategorizedVenuesSearchTab = UncategorizedVenuesSearchTab

class FlaggedVenuesSearchTab extends SearchManagerTab
  displayControls: ['global', 'near', 'box', 'circle', 'polygon']
  createSearch: (location = @locationManager.location()) ->
    new QueueSearch(@tab.find("#queue-name").val(), location)
window.FlaggedVenuesSearchTab = FlaggedVenuesSearchTab

class RecentlyCreatedTab extends SearchManagerTab
  displayControls: ['near', 'box', 'circle', 'polygon']
  createSearch: (location = @locationManager.location(true)) ->
    new RecentlyCreatedVenueSearch(location, {loadMoreContainer: @tab.find(".loadmorecontainer")})
window.RecentlyCreatedTab = RecentlyCreatedTab

class MyHistorySearchTab extends SearchManagerTab
  displayControls: ['global']
  setLocationTypeOnShown: 'global'
  createSearch: ()->
    new MyCheckinHistorySearch(@tab.find(".categories").select2('data').map((x) -> x.id), @tab.find(".myhistory-start").val(), @tab.find(".myhistory-end").val(), 1, {loadMoreContainer: @tab.find(".loadmorecontainer")})
  setupEvents: () ->
    new CategorySelector().setupCategories @tab.find("select.categories"),
      allowMultiple: true
      rotateButtonsSpanSelector: @tab.find(".catRotateButtons")
    @tab.find('.input-daterange').datepicker
      todayBtn: true
      todayHighlight: true
      endDate: new Date()
      autoclose: true
      format: "yyyy-mm-dd"
    super()

window.MyHistorySearchTab = MyHistorySearchTab

class ListSearchTab extends SearchManagerTab
  setLocationTypeOnShown: 'global'
  displayControls: ['global', 'box', 'polygon']

  setupEvents: () ->
    new CategorySelector().setupCategories @tab.find("select.categories"),
      allowMultiple: true
      rotateButtonsSpanSelector: @tab.find(".catRotateButtons")
    super()

  createSearch: (location = @locationManager.location()) ->
    new ListSearchByUrl(@tab.find(".listurl").val(), location, @tab.find(".categories").select2('data').map((x) -> x.id))
window.ListSearchTab = ListSearchTab


