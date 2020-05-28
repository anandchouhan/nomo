$(document).ready(function() {
  setDatetimePickerStartAtEvent(false);
  setDatetimePickerEndAtEvent(false, 0);
});

function setDatetimePickerStartAtEvent(isEdit) {
  $("input.start-at-event[data-edit='" + isEdit + "']").datetimepicker({
    format: 'm/d/Y',
    timepicker: false,
    minDate: 0,
    startDate: 0,
    scrollInput: false,
    onChangeDateTime: function(currentTime, input) {
      if (currentTime !== null) {
        $("input.event-start-at[data-edit='" + isEdit + "']").val(currentTime.toDateString());

        // Every time a user selects a start date, the end date input is cleared,
        // and its minDate is the selected start date.
        var endDateElement = $("input.end-at-event[data-edit='" + isEdit + "']");
        endDateElement.text('');
        endDateElement.val('');

        var minDate = formatToMinDate(currentTime);
        setDatetimePickerEndAtEvent(isEdit, minDate);
      }
    }
  });
}

function setDatetimePickerEndAtEvent(isEdit, minDate) {
  $("input.end-at-event[data-edit='" + isEdit + "']").datetimepicker({
    format: 'm/d/Y',
    timepicker: false,
    minDate: minDate,
    startDate: minDate,
    scrollInput: false,
    onChangeDateTime: function(currentTime, input) {
      if (currentTime !== null) {
        $("input.event-end-at[data-edit='" + isEdit + "']").val(currentTime.toDateString());
      }
    }
  });
}