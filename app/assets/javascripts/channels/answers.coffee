App.answers = App.cable.subscriptions.create({channel: 'AnswersChannel', id: gon.question_id}, {
  connected: ->

  disconnected: ->

  received: (data) ->
    if data.answer.user_id != gon.user_id
      $('.answers').append(JST["templates/answer"]({
        answer: data.answer,
        files: data.files,
        links: data.links
      }))
})
