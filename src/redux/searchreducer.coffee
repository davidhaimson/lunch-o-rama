{ Actions, Status } = require '../constants'

initialState = ->
  status: Status.IDLE
  searchText: ''
  filteredPlaces: []
  searchTags: []

searchPlaces = (placeInfo, tags, searchText) ->
  _placeInfo = _ placeInfo
  unless _.isEmpty tags
    _placeInfo = _placeInfo.filter (place) ->
      (_.intersection tags, place.tags).length
  if searchText
    _placeInfo = _placeInfo.filter (place) ->
      (place.name.toLowerCase().indexOf searchText.toLowerCase()) == 0
  _placeInfo.pluck 'name'
    .value()

shuffle = (array) ->
  currentIndex = array.length

  shuffled = _.clone array
  while currentIndex isnt 0
    randomIndex = Math.floor Math.random() * currentIndex
    currentIndex -= 1

    temporaryValue = shuffled[currentIndex]
    shuffled[currentIndex] = shuffled[randomIndex]
    shuffled[randomIndex] = temporaryValue

  shuffled

handlers =
  "#{Actions.SEARCH_PLACES}": (state, action) ->
    { payload } = action
    searchText: payload.searchText or ''
    filteredPlaces: searchPlaces payload.placeInfo, state.searchTags, payload.searchText

  "#{Actions.ADD_TAG}": (state, action) ->
    { payload } = action
    unless _.contains state.searchTags, payload.tag
      searchTags = state.searchTags.concat payload.tag

      status: Status.IDLE
      searchTags: searchTags
      filteredPlaces: searchPlaces payload.placeInfo, searchTags, state.searchText

  "#{Actions.REMOVE_TAG}": (state, action) ->
    { payload } = action
    if _.contains state.searchTags, payload.tag
      searchTags = _.without state.searchTags, payload.tag

      status: Status.IDLE
      searchTags: searchTags
      filteredPlaces: searchPlaces payload.placeInfo, searchTags, state.searchText

  "#{Actions.SELECT_PLACE}": (state, action) ->
    if action.meta?.promise
      status: Status.SPINNING
      filteredPlaces: shuffle state.filteredPlaces
    else if action.error
      status: Status.IDLE
    else
      status: Status.SELECTED

  "#{Actions.ADVANCE_SELECTION}": (state, action) ->
    filteredPlaces: (_.rest state.filteredPlaces).concat state.filteredPlaces[0]

module.exports = (state = initialState(), action) ->
  if handlers[action.type]
    newState = handlers[action.type] state, action
    unless _.isEmpty newState
      _.assign {}, state, newState
    else
      state
  else
    state
