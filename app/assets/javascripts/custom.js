$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover({
    trigger: 'focus'
  });

  $('[name="user[subscribtion_type]"]').click(function() {
    $('#additional-user-info').removeClass('d-none');
    if(this.value == '1') {
      $('#payment-user-info').removeClass('d-none');
    } else {
      $('#payment-user-info').addClass('d-none');
    }
  });

  $("#jquery_jplayer_1").jPlayer({
    ready: function (event) {
      $(this).jPlayer("setMedia", {
        title: "Bubble",
        m4a: "http://jplayer.org/audio/m4a/Miaow-07-Bubble.m4a",
        oga: "http://jplayer.org/audio/ogg/Miaow-07-Bubble.ogg"
      });
    },
    swfPath: "../../dist/jplayer",
    supplied: "m4a, oga",
    wmode: "window",
    useStateClassSkin: true,
    autoBlur: false,
    smoothPlayBar: true,
    keyEnabled: true,
    remainingDuration: true,
    toggleDuration: true
  });

  const notify = (selector) => {
    let obj = $(selector);
    if(obj.text().length > 0) {
      obj.show();
    }
  }

  notify('.notice');
  notify('.alert');

});

