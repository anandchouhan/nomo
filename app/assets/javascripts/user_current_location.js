$(document).on('click', '.dropdown-item-privacy-user-location', function(e) {
  var privacy = e.currentTarget.getAttribute('data-privacy');

  switch (privacy) {
    case '3':
      $("#privacy-user-location-icon").addClass("fa fa-globe");
      $("#privacy-user-location-label").text("Public");
      break;
    case '2':
      $("#privacy-user-location-icon").addClass("fa fa-unlock-alt");
      $("#privacy-user-location-label").text("Friends of Friends");
      break;
    case '1':
      $("#privacy-user-location-icon").addClass("fa fa-lock");
      $("#privacy-user-location-label").text("Friends");
      break;
    case '0':
      $("#privacy-user-location-icon").addClass("fa fa-lock");
      $("#privacy-user-location-label").text("Only Me");
      break;
  }

  $('#user-location-privacy').val(privacy);
});