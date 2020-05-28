$(document).ready(function() {
  assignDatetimePickerStartDateExplorer();
  assignDatetimePickerEndDateExplorer();
});

function assignDatetimePickerStartDateExplorer() {
  $("#start-date-explorer").datetimepicker({
    format:"m/d/Y",
    timepicker: false,
    onChangeDateTime: function(currentTime, input) {
      var selectedDate = input.val();

      var endDateElement = $("#end-date-explorer");
      endDateElement.text("");
      endDateElement.val("");
      endDateElement.datetimepicker({
        format:"m/d/Y",
        timepicker: false,
        minDate: selectedDate
      });
    }
  });
}

function assignDatetimePickerEndDateExplorer() {
  var selectedDate = $("#start-date-explorer").val();

  $("#end-date-explorer").datetimepicker({
    format:"m/d/Y",
    timepicker: false,
    minDate: selectedDate,
    startDate: selectedDate
  });
}
