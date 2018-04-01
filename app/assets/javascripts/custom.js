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

  $('.modal-blured').on('show.bs.modal', function () {
    $(this).prev('.main-container').css({'filter': 'blur(15px)'});
  });

  $('.modal-blured').on('hide.bs.modal', function (e) {
    $(this).prev('.main-container').css({'filter': 'blur(0px)'});
  });


  var client = algoliasearch("TOQ4XQOWDP", "90f548a9f6bb9108464d081db4c6a29a")
  var tracks = client.initIndex('Track');
  var releases = client.initIndex('Release');
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
              suggestion._highlightResult.title.value + '</span><span></span></a>';
          }
        }
      },
      {
        source: autocomplete.sources.hits(releases, { hitsPerPage: 3 }),
        displayKey: 'title',
        templates: {
          header: '<div class="aa-suggestions-category">Releases</div>',
          suggestion: function(suggestion) {
            return '<a href="/releases/'+suggestion.objectID+'"><span>' +
              suggestion._highlightResult.title.value + '</span><span>'
                + suggestion._highlightResult.text.value + '</span></a>';
          }
        }
      },
      {
        source: autocomplete.sources.hits(users, { hitsPerPage: 3 }),
        displayKey: 'name',
        templates: {
          header: '<div class="aa-suggestions-category">Users</div>',
          suggestion: function(suggestion) {
            return '<a href="/users/'+suggestion.objectID+'"><span>' +
              suggestion._highlightResult.name.value + '</span><span></span></a>';
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
              suggestion._highlightResult.title.value + '</span><span>'
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

});

