$(document).ready(function() {
  $('#notifications').on('click', function() {
    $('.notification-content').parents("div.popover").addClass("parent-notification");
  });

  $('#notifications').on('hidden.bs.popover', function() {
    $('#notification-count').hide();
  });
});

$(document).on('click', '#btn-load-more-notifications', function(e) {
  var nextOffset = $('#next-offset').text();
  var url = '/notifications/scroll_refresh?offset=' + nextOffset;

  var target = e.currentTarget;
  target.setAttribute("disabled", "disabled");

  $.ajax({
    url: url,
    dataType: 'script',
    contentType: 'application/javascript',
    complete: function complete(jqXHR, textStatus) {
      target.removeAttribute("disabled");
    }
  });
});