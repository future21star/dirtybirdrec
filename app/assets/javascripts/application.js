// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require_tree .

$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover({
    trigger: 'focus'
  })

  $('[name="user[subscribtion_type]"]').click(function() {
    $('#additional-user-info').removeClass('d-none');
    if(this.value == '1') {
      $('#payment-user-info').removeClass('d-none');
    } else {
      $('#payment-user-info').addClass('d-none');
    }
  });
})

