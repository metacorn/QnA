@startQuestionsSubscription = ->
  App.questions = App.cable.subscriptions.create "QuestionsChannel",
    connected: ->

    disconnected: ->

    received: (data) ->
      $('.questions').append(JST["templates/question"]({
        question: data.question
      }))
