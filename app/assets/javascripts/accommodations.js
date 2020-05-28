$(document).ready(function() {
  setDatetimePickerArrivingAtAccommodation(false);
  setDatetimePickerDepartingAtAccommodation(false, 0);
});

function setDatetimePickerArrivingAtAccommodation(isEdit) {
  $("input.arriving-at-accommodation[data-edit='" + isEdit + "']").datetimepicker({
    format: 'm/d/Y',
    timepicker: false,
    minDate: 0,
    startDate: 0,
    scrollInput: false,
    onChangeDateTime: function(currentTime, input) {
      if (currentTime !== null) {
        $("input.accommodation-arriving-at[data-edit='" + isEdit + "']").val(currentTime.toDateString());

        // Every time a user selects a start date, the end date input is cleared,
        // and its minDate is the selected start date.
        var endDateElement = $("input.departing-at-accommodation[data-edit='" + isEdit + "']");
        endDateElement.text('');
        endDateElement.val('');

        var minDate = formatToMinDate(currentTime);
        setDatetimePickerDepartingAtAccommodation(isEdit, minDate);
      }
    }
  });
}

function setDatetimePickerDepartingAtAccommodation(isEdit, minDate) {
  $("input.departing-at-accommodation[data-edit='" + isEdit + "']").datetimepicker({
    format: 'm/d/Y',
    timepicker: false,
    minDate: minDate,
    startDate: minDate,
    scrollInput: false,
    onChangeDateTime: function(currentTime, input) {
      if (currentTime !== null) {
        $("input.accommodation-departing-at[data-edit='" + isEdit + "']").val(currentTime.toDateString());
      }
    }
  });
}