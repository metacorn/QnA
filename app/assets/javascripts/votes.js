$(document).on('ajax:success', '.votes', function(e) {
  var response = e.detail[0]

  var rating = response.rating
  $(this).find('span.rating').html(rating)

  var kind = response.kind
  if (kind == "positive") {
    $(this).find('span.vote-down').replaceWith('<span class="vote-down">down</span> ')
    $(this).find('span.vote-up').replaceWith('<span class="vote-up font-weight-bold">up</span> ')
  } else if (kind == "negative") {
    $(this).find('span.vote-down').replaceWith('<span class="vote-down font-weight-bold">down</span> ')
    $(this).find('span.vote-up').replaceWith('<span class="vote-up">up</span> ')
  }

  $(this).find('span.cancel-vote-link').html('<a href="#">Cancel</a>')
})
