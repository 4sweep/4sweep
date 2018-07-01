class Listeners
  # events is the list of known events that could be fired. an exception is
  # thrown if somebody tries to subscribe to an unknown event or if somebody
  # tries to notify on an unknown event
  constructor: (events = []) ->
    @listeners = {}
    @listeners[e] = {} for e in events

  # returns an ID that can be used to remove the listener later
  add: (event, listener) ->
    if event.match(" ")
      return (@add(e, listener) for e in (event.split(" ")))

    throw "Unknown event #{event}" unless @listeners[event]

    uuid  =
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
        r = Math.random() * 16 | 0
        v = if c is 'x' then r else (r & 0x3|0x8)
        v.toString(16)
      )
    @listeners[event][uuid] = listener
    uuid

  notify: (event, args...) ->
    throw "Unknown event #{event}" unless @listeners[event]
    for own id, listener of (@listeners[event])
      listener(args...)

  remove: (event, listenerId) ->
    throw "Unknown event #{event}" unless @listeners[event]
    delete @listeners[event][listenerId]

window.Listeners = Listeners
