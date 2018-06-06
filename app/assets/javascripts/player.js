$(document).on('turbolinks:load', () => {
  // $('.navbar').css('top', '40px');
  $('.main-container main').css('padding-top', '100px');

  $('.main-container main').on('click', '.jp-play-release', function(){
    playButton();
  });

  $('.main-container main').on('click', '.jp-play-track', function(){
    playTrack($(this).data('track'));
  });

  $('.main-container main').on('click', '.jp-play-release', function(){
    playRelease($(this).data('release'));
  });

  $('.main-container main').on('click', '.jp-previous', function(){
    playPrevious();
  });

  $('.main-container main').on('click', '.jp-next', function(){
    playNext();
  });

  updateCPlayerState();
});
