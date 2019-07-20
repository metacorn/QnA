@startCommentsSubscription = ->
  App.comments = App.cable.subscriptions.create({channel: 'CommentsChannel', id: gon.question_id}, {
    connected: ->

    disconnected: ->

    received: (data) ->
      if data.comment.user_id != gon.user_id
        $("##{data.comment.commentable_type.toLowerCase()}_#{data.comment.commentable_id}").find('.comments-list').append(JST["templates/comment"]({
          comment: data.comment
        }))
  })
