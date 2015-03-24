define ->

  init = (options)->
    console.log 'working!'

  return {
    aPAGE: (options)->
      init(options)
  }