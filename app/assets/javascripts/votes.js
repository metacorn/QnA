$(document).on('ajax:success', '.votes', function(e) {
  var rating = e.detail[0].rating
  $(this).find('span.rating').html(rating)
})
