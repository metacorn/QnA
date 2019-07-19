$(document).on "turbolinks:load", ->
  stopAllSubscriptions()

  pathname = document.location.pathname

  if (pathname == '/' || pathname == '/questions')
    startQuestionsSubscription()

  if (/\/questions\/\d+/.test(pathname))
    startAnswersSubscription()

@stopAllSubscriptions = ->
  if subscriptions = App.cable.subscriptions.subscriptions
    for subscription in subscriptions
      subscription.unsubscribe()
