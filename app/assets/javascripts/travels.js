$(document).ready(function() {
  setDatetimePickerDepartingAtTravel(false);
  setDatetimePickerArrivingAtTravel(false, 0);
});

function setDatetimePickerDepartingAtTravel(isEdit) {
  $("input.departing-at-travel[data-edit='" + isEdit + "']").datetimepicker({
    format: 'm/d/Y',
    timepicker: false,
    minDate: 0,
    startDate: 0,
    scrollInput: false,
    onChangeDateTime: function(currentTime, input) {
      if (currentTime !== null) {
        $("input.travel-departing-at[data-edit='" + isEdit + "']").val(currentTime.toDateString());

        // Every time a user selects a start date, the end date input is cleared,
        // and its minDate is the selected start date.
        var endDateElement = $("input.arriving-at-travel[data-edit='" + isEdit + "']");
        endDateElement.text('');
        endDateElement.val('');

        var minDate = formatToMinDate(currentTime);
        setDatetimePickerArrivingAtTravel(isEdit, minDate);
      }
    }
  });
}

function setDatetimePickerArrivingAtTravel(isEdit, minDate) {
  $("input.arriving-at-travel[data-edit='" + isEdit + "']").datetimepicker({
    format: 'm/d/Y',
    timepicker: false,
    minDate: minDate,
    startDate: minDate,
    scrollInput: false,
    onChangeDateTime: function(currentTime, input) {
      if (currentTime !== null) {
        $("input.travel-arriving-at[data-edit='" + isEdit + "']").val(currentTime.toDateString());
      }
    }
  });
}