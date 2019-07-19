$(document).on "turbolinks:load", ->
  deleteAllSubscriptions()

  pathname = document.location.pathname

  if (pathname == '/' || pathname == '/questions')
    startQuestionsSubscription()

  if (/\/questions\/\d+/.test(pathname))
    startAnswersSubscription()

@deleteAllSubscriptions = ->
  App.cable.disconnect()
