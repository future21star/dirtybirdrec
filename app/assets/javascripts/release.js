$(document).on('turbolinks:load', function() {
  let rate = $('#rate_number').val();
  if (rate.trim() == "") {
    $('.rate-stars').hide();
    $('.rate-word').show();
  } else {
    $('.rate-stars').show();
    $('.rate-word').hide();
  }  

  $('.rate-word').click(function() {
    $('.rate-stars').show();
    $('.rate-word').hide();
  })
})