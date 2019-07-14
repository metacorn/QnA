$(document).on('ajax:success', '.votes', function(e) {
  // json response
  var response = e.detail[0]

  // elements
  var downVoteSpan = $(this).find('span.vote-down')
  var ratingSpan = $(this).find('span.rating')
  var upVoteSpan = $(this).find('span.vote-up')
  var cancelVoteSpan = $(this).find('span.cancel-vote')

  // down vote span
  if (response.down_vote_state == 'active') {
    downVoteSpan.removeClass('text-muted')
    downVoteSpan.removeClass('font-weight-bold')
    downVoteSpan.html(downVoteLinkTag()).append(' ')
  } else if (response.down_vote_state == 'highlighted') {
    downVoteSpan.addClass('font-weight-bold')
    downVoteSpan.removeClass('text-muted')
    downVoteSpan.html('down').append(' ')
  } else if (response.down_vote_state == 'inactive') {
    downVoteSpan.addClass('text-muted')
    downVoteSpan.removeClass('font-weight-bold')
    downVoteSpan.html('down').append(' ')
  }

  // response.rating span
  ratingSpan.html(response.rating)

  // up vote span
  if (response.up_vote_state == 'active') {
    upVoteSpan.removeClass('text-muted')
    upVoteSpan.removeClass('font-weight-bold')
    upVoteSpan.html(upVoteLinkTag()).append(' ')
  } else if (response.up_vote_state == 'highlighted') {
    upVoteSpan.addClass('font-weight-bold')
    upVoteSpan.removeClass('text-muted')
    upVoteSpan.html('up').append(' ')
  } else if (response.up_vote_state == 'inactive') {
    upVoteSpan.addClass('text-muted')
    upVoteSpan.removeClass('font-weight-bold')
    upVoteSpan.html('up').append(' ')
  }

  // cancel vote span
  if (response.cancel_vote_state == 'active') {
    cancelVoteSpan.html(cancelVoteLinkTag())
  } else if (response.cancel_vote_state == 'inactive') {
    cancelVoteSpan.html('')
  }

  // functions
  function upVoteLinkTag() {
    return '<a data-type="json" data-remote="true" rel="nofollow" data-method="post" href="/' + response.votable_controller + '/' + response.votable_id + '/vote_up">up</a>'
  }

  function downVoteLinkTag() {
    return '<a data-type="json" data-remote="true" rel="nofollow" data-method="post" href="/' + response.votable_controller + '/' + response.votable_id + '/vote_down">down</a>'
  }

  function cancelVoteLinkTag() {
    return '<a data-type="json" data-remote="true" rel="nofollow" data-method="delete" href="/' + response.votable_controller + '/' + response.votable_id + '/cancel_vote">Cancel</a>'
  }
})
