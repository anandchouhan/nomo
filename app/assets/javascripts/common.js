$(document).ready(function() {
  $(document).on('click', '.click-reveal', function() {
    var showId = $(this).attr("id") + "Container";
    
    $('.click-reveal-element').hide();
    $('.click-reveal').removeClass("active");
    $(this).addClass("active");
    $("#" + showId).show();
  });
})