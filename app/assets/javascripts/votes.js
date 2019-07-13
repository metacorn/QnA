$(document).on('ajax:success', '.votes', function(e) {
  // json response
  var response = e.detail[0]

  // data from json response
  var downVoteState = response.down_vote_state
  var upVoteState = response.up_vote_state
  var rating = response.rating
  var cancelVoteState = response.cancel_vote_state
  var votableController = response.votable_controller
  var votableId = response.votable_id

  console.log(response)

  // elements
  var downVoteSpan = $(this).find('span.vote-down')
  var ratingSpan = $(this).find('span.rating')
  var upVoteSpan = $(this).find('span.vote-up')
  var cancelVoteSpan = $(this).find('span.cancel-vote')

  // down vote span
  if (downVoteState == 'active') {
    downVoteSpan.removeClass('text-muted')
    downVoteSpan.removeClass('font-weight-bold')
    downVoteSpan.html(downVoteLinkTag(votableController, votableId)).append(' ')
  } else if (downVoteState == 'highlighted') {
    downVoteSpan.addClass('font-weight-bold')
    downVoteSpan.removeClass('text-muted')
    downVoteSpan.html('down').append(' ')
  } else if (downVoteState == 'inactive') {
    downVoteSpan.addClass('text-muted')
    downVoteSpan.removeClass('font-weight-bold')
    downVoteSpan.html('down').append(' ')
  }

  // rating span
  ratingSpan.html(rating)

  // up vote span
  if (upVoteState == 'active') {
    upVoteSpan.removeClass('text-muted')
    upVoteSpan.removeClass('font-weight-bold')
    upVoteSpan.html(upVoteLinkTag(votableController, votableId)).append(' ')
  } else if (upVoteState == 'highlighted') {
    upVoteSpan.addClass('font-weight-bold')
    upVoteSpan.removeClass('text-muted')
    upVoteSpan.html('up').append(' ')
  } else if (upVoteState == 'inactive') {
    upVoteSpan.addClass('text-muted')
    upVoteSpan.removeClass('font-weight-bold')
    upVoteSpan.html('up').append(' ')
  }

  // cancel vote span
  if (cancelVoteState == 'active') {
    cancelVoteSpan.html(cancelVoteLinkTag(votableController, votableId))
  } else if (cancelVoteState == 'inactive') {
    cancelVoteSpan.html('')
  }

  // functions
  function upVoteLinkTag(votableController, votableId) {
    return '<a data-type="json" data-remote="true" rel="nofollow" data-method="post" href="/' + votableController + '/' + votableId + '/vote_up">up</a>'
  }

  function downVoteLinkTag(votableController, votableId) {
    return '<a data-type="json" data-remote="true" rel="nofollow" data-method="post" href="/' + votableController + '/' + votableId + '/vote_down">down</a>'
  }

  function cancelVoteLinkTag(votableController, votableId) {
    return '<a data-type="json" data-remote="true" rel="nofollow" data-method="delete" href="/' + votableController + '/' + votableId + '/cancel_vote">Cancel</a>'
  }
})
