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
    setVoteSpanActive(downVoteSpan)
  } else if (response.down_vote_state == 'highlighted') {
    setVoteSpanHighlited(downVoteSpan)
  } else if (response.down_vote_state == 'inactive') {
    setVoteSpanInactive(downVoteSpan)
  }

  // rating span
  ratingSpan.html(response.rating)

  // up vote span
  if (response.up_vote_state == 'active') {
    setVoteSpanActive(upVoteSpan)
  } else if (response.up_vote_state == 'highlighted') {
    setVoteSpanHighlited(upVoteSpan)
  } else if (response.up_vote_state == 'inactive') {
    setVoteSpanInactive(upVoteSpan)
  }

  // cancel vote span
  if (response.cancel_vote_state == 'active') {
    cancelVoteSpan.html(cancelVoteLinkTag())
  } else if (response.cancel_vote_state == 'inactive') {
    cancelVoteSpan.html('')
  }

  // functions
  function cancelVoteLinkTag() {
    return '<a data-type="json" data-remote="true" rel="nofollow" data-method="delete" href="/' + response.votable_controller + '/' + response.votable_id + '/cancel_vote">Cancel</a>'
  }

  function voteLinkTag(voteKind) {
    return '<a data-type="json" data-remote="true" rel="nofollow" data-method="post" href="/' + response.votable_controller + '/' + response.votable_id + '/vote_' + voteKind + '">' + voteKind + '</a>'
  }

  function setVoteSpanActive(span) {
    span.removeClass('text-muted')
    span.removeClass('font-weight-bold')
    var voteKind = setVoteKind(span)
    span.html(voteLinkTag(voteKind)).append(' ')
  }

  function setVoteSpanHighlited(span) {
    span.addClass('font-weight-bold')
    span.removeClass('text-muted')
    var voteKind = setVoteKind(span)
    span.html(voteKind).append(' ')
  }

  function setVoteSpanInactive(span) {
    span.addClass('text-muted')
    span.removeClass('font-weight-bold')
    var voteKind = setVoteKind(span)
    span.html(voteKind).append(' ')
  }

  function setVoteKind(span) {
    if (span == downVoteSpan) {
      return 'down'
    } else if (span == upVoteSpan) {
      return 'up'
    }
  }
})
