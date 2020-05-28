$(document).ready(function () {
  $("#calendar").fullCalendar({
    height: "auto",
    header: {
      left: "prev,next today",
      center: "title",
      right: "month,agendaWeek,agendaDay"
    },
    events: "/trip_locations.json",
    editable: false,
    eventClick: function eventClick(event, jsEvent, view) {
      window.location.href = "/trips/" + event.trip_id + "/locations/" + event.id;
    },
    eventRender: function eventRender(event, element) {
      element.find(".fc-title").append("<p>" + event.name + "</p>");
    }
  });
});
