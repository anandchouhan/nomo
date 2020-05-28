$(document).on('click', '#btn-load-more-feed', function(e) {
  var filter = getUrlParameter(window.location.href, 'filter');
  if (filter === '') {
    filter = 'public';
  }

  var nextOffset = $('#next-offset').text();
  var url = '/activities/scroll_refresh?offset=' + nextOffset + '&filter=' + filter;

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

$(document).on('click', '.show-comments', function(event) {
  var activityId = event.currentTarget.getAttribute('data-activity-id');
  var url = '/activities/' + activityId + '/comments';

  $.ajax({
    url: url,
    dataType: 'html',
    success: function success(data) {
      $('.activity-comments-list[data-activity-id="' + activityId + '"]').html(data);
      $('.modal[data-activity-id="' + activityId + '"]').modal('show');
      $('.scrollable').mCustomScrollbar({theme: 'minimal-dark'});
    }
  });
});

$(document).on('click', '.dropdown-item-activities-filter', function(e) {
  var filter = e.currentTarget.getAttribute('data-filter');

  switch (filter) {
    case 'public':
      $("#activities-filter-icon").addClass("fa fa-globe");
      $("#activities-filter-label").text("Public");
      break;
    case 'friends-of-friends':
      $("#activities-filter-icon").addClass("fa fa-unlock-alt");
      $("#activities-filter-label").text("Friends of Friends");
      break;
    case 'friends':
      $("#activities-filter-icon").addClass("fa fa-lock");
      $("#activities-filter-label").text("Friends");
      break;
  }
});
