$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover({
    trigger: 'focus'
  });

  $('[name="user[subscription_type]"]').click(function() {
    $('#additional-user-info').removeClass('d-none');
    if(this.value == 'vip') {
      $('#payment-user-info').removeClass('d-none');
    } else {
      $('#payment-user-info').addClass('d-none');
    }
  });

  if($('#user_subscription_type_vip:checked').length > 0) {
    $('#payment-user-info').removeClass('d-none');
  }

  const notify = (selector) => {
    let obj = $(selector);
    if(obj.text().length > 0) {
      obj.show();
      setTimeout(function(){
        obj.fadeOut('slow');
      },3000);
    }
  };
  notify('.notice');
  notify('.alert');

  $('.modal-blured').on('show.bs.modal', function () {
    $(this).siblings('.main-container').css({'filter': 'blur(15px)'});
  });

  $('#searchModal').on('shown.bs.modal', function () {
    var client = algoliasearch("TOQ4XQOWDP", "90f548a9f6bb9108464d081db4c6a29a")
    var tracks = client.initIndex('Track');
    var releases = client.initIndex('Release');//.setSettings({attributesToSnippet: ['text:3','title']});
    var users = client.initIndex('User');
    var topics = client.initIndex('Topic');
    var posts = client.initIndex('Post');

    autocomplete('#aa-search-input', {}, [
        {
          source: autocomplete.sources.hits(tracks, { hitsPerPage: 3 }),
          displayKey: 'title',
          templates: {
            header: '<div class="aa-suggestions-category">Tracks</div>',
            suggestion: function(suggestion) {
              return '<a href="/tracks/'+suggestion.objectID+'"><span>' +
                suggestion._highlightResult.title.value + '</span></a>';
            }
          }
        },
        {
          source: autocomplete.sources.hits(releases, { hitsPerPage: 3 }),
          displayKey: 'title',
          templates: {
            header: '<div class="aa-suggestions-category">Releases</div>',
            suggestion: function(suggestion) {
              return '<a href="/releases/'+suggestion.objectID+'"><span><i>' +
                suggestion._highlightResult.title.value + '</i> '
                  + suggestion._highlightResult.text.value + '</span></a>';
            }
          }
        },
        {
          source: autocomplete.sources.hits(users, { hitsPerPage: 3 }),
          displayKey: 'first_name',
          templates: {
            header: '<div class="aa-suggestions-category">Users</div>',
            suggestion: function(suggestion) {
              return '<a href="/users/'+suggestion.objectID+'"><span>' +
                suggestion._highlightResult.first_name.value + ' ' +
                suggestion._highlightResult.last_name.value +'</span></a>';
            }
          }
        },
        {
          source: autocomplete.sources.hits(topics, { hitsPerPage: 3 }),
          displayKey: 'title',
          templates: {
            header: '<div class="aa-suggestions-category">Topics</div>',
            suggestion: function(suggestion) {
              return '<a href="/topics/'+suggestion.objectID+'"><span>' +
                suggestion._highlightResult.title.value 
                  + suggestion._highlightResult.text.value + '</span></a>';
            }
          }
        },
        {
          source: autocomplete.sources.hits(posts, { hitsPerPage: 3 }),
          displayKey: 'text',
          templates: {
            header: '<div class="aa-suggestions-category">Posts</div>',
            suggestion: function(suggestion) {
              return '<a href="/chirp/'+suggestion.objectID+'"><span>' +
                suggestion._highlightResult.text.value + '</span>';
            }
          }
        }
    ]);
    
    $('#aa-search-input').focus();
  });

  $('.modal-blured').on('hide.bs.modal', function (e) {
    if ($('.modal-backdrop.show').length == 1) {
      $(this).siblings('.main-container').css({'filter': 'blur(0px)'});
    }
  });

  let avatar_form = document.querySelector('#change-avatar');
  $(avatar_form).find('#user_avatar').change(function(){
    avatar_form.dispatchEvent(new Event('submit', {bubbles: true}));
  });

  $('.truncated-description').on('click', '.truncated-long', function(){
    $(this).hide();
    $(this).prev('article').hide();
    $(this).next('article').show();
    $('.truncated-short').show();
    return false;
  });

  $('.truncated-description').on('click', '.truncated-short', function(){
    $(this).siblings('article').show();
    $(this).siblings('article').last().hide();
    $(this).hide();
    $('.truncated-long').show();
    return false;
  });

  $('.dropdown-notify-menu').on("show.bs.dropdown", function(event){
    $.get( "/is_seen", function() {});
    $('.nav-notify-count').hide();
  });

  $('.dropdown-notify-menu').on("hide.bs.dropdown", function(event){
    $('.dropdown-notify-menu .notify-seen').removeClass('notify-seen');
  });

  $('.notice').click(function(){$(this).hide()});
  $('.alert').click(function(){$(this).hide()});

  $('.scroll-bottom').click(function(){
    $("html, body").animate({ scrollTop: $(document).height() }, 500);
  });

  $('.show-more-comments').click(function(){
    $(this).siblings('.feed-replies-list').find('div').show();
    $(this).hide();
    return false;
  });

  if (window.location.hash !== "") {
    $('html, body').animate({
      scrollTop: $(window.location.hash).offset().top - 120
    }, 600, function(){});
  }

});
