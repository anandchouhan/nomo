$(document).on('click', '.dropdown-item-post-privacy', function(e) {
  var privacy = e.currentTarget.getAttribute('data-privacy');

  switch (privacy) {
    case '3':
      $("#privacy-post-icon").addClass("fa fa-globe");
      $("#privacy-post-label").text("Public");
      break;
    case '2':
      $("#privacy-post-icon").addClass("fa fa-unlock-alt");
      $("#privacy-post-label").text("Friends of Friends");
      break;
    case '1':
      $("#privacy-post-icon").addClass("fa fa-lock");
      $("#privacy-post-label").text("Friends");
      break;
    case '0':
      $("#privacy-post-icon").addClass("fa fa-user");
      $("#privacy-post-label").text("Only Me");
      break;
  }

  $('#privacy-post').val(privacy);
});
