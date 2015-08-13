{ Actions, Status } = require '../constants'
searchReducer = require './searchreducer'

describe 'Search Reducer', ->

  it 'should provide initial state', ->
    state = searchReducer null, type: 'initialize'

    (expect state.status).to.equal Status.IDLE

  it 'should add tags to the list to filter places', ->
    state = searchReducer searchTags: [ 'first' ],
      type: Actions.ADD_TAG
      payload: { tag: 'second', placeInfo: [] }

    (expect state.searchTags).to.deep.equal [ 'first', 'second' ]

  it 'should not modify state when adding tags already in the list', ->
    current = searchTags: [ 'first' ]
    state = searchReducer current,
      type: Actions.ADD_TAG
      payload: { tag: 'first', placeInfo: [] }

    (expect state).to.equal current
    (expect state.searchTags).to.deep.equal [ 'first' ]

  it 'should remove tags to the list to filter places', ->
    state = searchReducer searchTags: [ 'first', 'second' ],
      type: Actions.REMOVE_TAG
      payload: { tag: 'second', placeInfo: [] }

    (expect state.searchTags).to.deep.equal [ 'first' ]

  it 'should filter places by nothing, if no tags and no search text', ->
    placeInfo = [
      { name: 'First Place', tags: [ 'second' ] }
      { name: 'Second Place', tags: [ 'first' ] }
    ]
    state = searchReducer searchTags: [],
      type: Actions.SEARCH_PLACES
      payload:
        searchText: ''
        placeInfo: placeInfo

    (expect state.filteredPlaces.length).to.equal placeInfo.length

  it 'should filter places by tags', ->
    state = searchReducer searchTags: [ 'first' ],
      type: Actions.SEARCH_PLACES
      payload:
        placeInfo: [
          { name: 'First Place', tags: [ 'second' ] }
          { name: 'Second Place', tags: [ 'first' ] }
        ]

    (expect state.filteredPlaces).to.deep.equal [ 'Second Place' ]

  it 'should filter places by search text, case-insensitively', ->
    state = searchReducer searchTags: [],
      type: Actions.SEARCH_PLACES
      payload:
        searchText: 'f'
        placeInfo: [
          { name: 'First Place', tags: [ 'second' ] }
          { name: 'Second Place', tags: [ 'first' ] }
        ]

    (expect state.filteredPlaces).to.deep.equal [ 'First Place' ]

  it 'should filter places both by tags and by search text, case-insensitively', ->
    state = searchReducer searchTags: [ 'first', 'second' ],
      type: Actions.SEARCH_PLACES
      payload:
        searchText: 'f'
        placeInfo: [
          { name: 'First Place', tags: [ 'second' ] }
          { name: 'Second Place', tags: [ 'third' ] }
          { name: 'Fourth Place', tags: [ 'first' ] }
        ]

    (expect state.filteredPlaces).to.deep.equal [ 'First Place', 'Fourth Place' ]