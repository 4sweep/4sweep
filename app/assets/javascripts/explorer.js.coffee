#= require ./search/Listeners
#= require ./search/Explorer
#= require ./search/Searches/Search
#= require ./search/Searches/VenueSearch
#= require ./search/Searches/UserSearch
#= require ./search/SearchLocation/SearchLocation
#= require_tree ./search/

@API_VERSION = "20140810"

window.STACK_BOTTOMRIGHT = {"dir1": "up", "dir2": "left", "firstpos1": 25, "firstpos2": 25, "spacing1": 0, "spacing2": 0};
window.STACK_BOTTOMLEFT = {"dir1": "up", "dir2": "right"};
$.pnotify.defaults.history = false

$().ready ->
  explorer = new Explorer($("body"))
