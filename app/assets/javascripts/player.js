$(document).on('turbolinks:load', () => {
  $('.jp-volume-btn').click(() => {
    $('.jp-volume').toggleClass('d-flex').toggleClass('d-none');
  });

  // $('#jp_container_1').mouseover(function() {
    $('#jp_container_1').css({'top': '0px'});
    // $(this).css({'top': '0px'});
    $('.navbar').css('top', '40px');
    $('.main-container main').css('padding-top', '100px');
    $('.jp-controls').css('opacity', '1');
    $('.jp-details').css('top', '0px');
  // });

  // $('#jp_container_1').mouseout(function() {
  //   $(this).css({'top': '-20px'});
  //   $('.navbar').css('top', '20px');
  //   $('header').css('margin-bottom', '80px');
  //   $('.jp-controls').css('opacity', '0');
  //   $('.jp-details').css('top', '10px');
  // });

});
