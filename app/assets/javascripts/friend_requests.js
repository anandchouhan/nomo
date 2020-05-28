$(document).ready(function() {
  $(document).on('keyup', '#search-friends', function(event) {

    // Waits for 750 milliseconds before sending the Ajax request.
    // This is to avoid too many hits to the database if the user is typing.
    delay(function() {
      var value = event.target.value.trim();
      if (value.length > 0) {
        var params = {search: value};
        var url = '/users/lookup?' + $.param(params);

        $.ajax({
          url: url,
          type: 'get',
          dataType: 'html',
          success: function success(data) {
            $('#friends-search-list').html(data);
          }
        });
      } else {
        $('#friends-search-list').empty();
      }
    }, 750);

  });
});
