$(document).ready(function() {
  // Initializes datepickers for the modal to create trips.
  setDatetimePickerStartAt(false, 0);
  setDatetimePickerEndAt(false, 0, 0);
});

$(document).on('submit', '#new-trip-form', function(event) {
  validateTripForm(false, event);
});

$(document).on('submit', '#edit-trip-form', function(event) {
  validateTripForm(true, event);
});

// Validates trip forms like creation and edition.
// Provides immediate feedback for users about inputs.
function validateTripForm(isEdit, event) {
  var isValid = true;

  var nameElement = isEdit ? $("#edit-trip-form input[name='trip[name]']") : $("#new-trip-form input[name='trip[name]']");
  if (nameElement.val() === '') {
    isValid = false;
    nameElement.addClass('validation-error');
  } else {
    nameElement.removeClass('validation-error');
  }

  var numberOfLocations = isEdit ? $('.locations-index-edit').val() : $('.locations-index').val();
  for (var i = 0; i <= numberOfLocations; i++) {
    var locationIdElement = $("input[name='trip[trip_locations_attributes[" + i + "][location_id]]'][data-edit='" + isEdit + "']");
    var locationInput = $("input.autocomplete-places[data-edit='" + isEdit + "'][data-index='" + i + "']");
    if (locationIdElement.val() === '') {
      isValid = false;
      locationInput.addClass('validation-error');
    } else {
      locationInput.removeClass('validation-error');
    }

    var startAtElement = $("input[name='trip[trip_locations_attributes[" + i + "][start_at]]'][data-edit='" + isEdit + "']");
    var startAtInput = $("input.start-date-trip[data-edit='" + isEdit + "'][data-index='" + i + "']");
    if (startAtElement.val() === '') {
      isValid = false;
      startAtInput.addClass('validation-error');
    } else {
      startAtInput.removeClass('validation-error');
    }

    var endAtElement = $("input[name='trip[trip_locations_attributes[" + i + "][end_at]]'][data-edit='" + isEdit + "']");
    var endAtInput = $("input.end-date-trip[data-edit='" + isEdit + "'][data-index='" + i + "']");
    if (endAtElement.val() === '') {
      isValid = false;
      endAtInput.addClass('validation-error');
    } else {
      endAtInput.removeClass('validation-error');
    }
  }

  if (isValid) {
    if (isEdit) {
      $('#edit-trip-form input[type=submit]').prop('disabled', true);
    } else {
      $('#new-trip-form input[type=submit]').prop('disabled', true);
    }
  } else {
    event.preventDefault();
    event.stopPropagation();
  }
}

// Sets a datetimepicker to a specific start date input.
function setDatetimePickerStartAt(isEdit, index) {
  $("input.start-date-trip[data-edit='" + isEdit + "'][data-index='" + index + "']").datetimepicker({
    format: 'm/d/Y',
    timepicker: false,
    minDate: 0,
    startDate: 0,
    scrollInput: false,
    onChangeDateTime: function(currentTime, input) {
      if (currentTime !== null) {
        $("input.trip-start-date[data-edit='" + isEdit + "'][data-index='" + index + "']").val(currentTime.toDateString());

        // Every time a user selects a start date, the end date input is cleared,
        // and its minDate is the selected start date.
        var endDateElement = $("input.end-date-trip[data-edit='" + isEdit + "'][data-index='" + index + "']");
        endDateElement.text('');
        endDateElement.val('');

        var minDate = formatToMinDate(currentTime);
        setDatetimePickerEndAt(isEdit, index, minDate);
      }
    }
  });
}

// Sets a datetimepicker to a specific end date input.
function setDatetimePickerEndAt(isEdit, index, minDate) {
  $("input.end-date-trip[data-edit='" + isEdit + "'][data-index='" + index + "']").datetimepicker({
    format: 'm/d/Y',
    timepicker: false,
    minDate: minDate,
    startDate: minDate,
    scrollInput: false,
    onChangeDateTime: function(currentTime, input) {
      if (currentTime !== null) {
        $("input.trip-end-date[data-edit='" + isEdit + "'][data-index='" + index + "']").val(currentTime.toDateString());
      }
    }
  });
}

$(document).on("click", ".add-city", function() {
  onAddCityClick(false);
});

$(document).on("click", ".add-city-edit", function() {
  onAddCityClick(true);
});

$(document).on("click", ".dropdown-item-privacy-create", function(e) {
  var privacy = $(e.currentTarget).data("privacy");
  $("#privacy-settings-create").attr("value", privacy);

  $("#privacy-setting-icon-create").removeClass();

  if (privacy === "Public") {
    $("#privacy-setting-icon-create").addClass("fa fa-globe");
    $("#privacy-setting-name-create").text("Public");
  } else if (privacy === "FriendsOfFriends") {
    $("#privacy-setting-icon-create").addClass("fa fa-unlock-alt");
    $("#privacy-setting-name-create").text("Friends of Friends");
  } else if (privacy === "MyNetwork") {
    $("#privacy-setting-icon-create").addClass("fa fa-lock");
    $("#privacy-setting-name-create").text("Friends");
  } else if (privacy === "JustMe") {
    $("#privacy-setting-icon-create").addClass("fa fa-user");
    $("#privacy-setting-name-create").text("Only Me");
  }
});

$(document).on("click", ".dropdown-item-privacy-edit", function(e) {
  var privacy = $(e.currentTarget).data("privacy");
  $("#privacy-settings-edit").attr("value", privacy);

  $("#privacy-setting-icon-edit").removeClass();

  if (privacy === "Public") {
    $("#privacy-setting-icon-edit").addClass("fa fa-globe");
    $("#privacy-setting-name-edit").text("Public");
  } else if (privacy === "FriendsOfFriends") {
    $("#privacy-setting-icon-edit").addClass("fa fa-unlock-alt");
    $("#privacy-setting-name-edit").text("Friends of Friends");
  } else if (privacy === "MyNetwork") {
    $("#privacy-setting-icon-edit").addClass("fa fa-lock");
    $("#privacy-setting-name-edit").text("Friends");
  } else if (privacy === "JustMe") {
    $("#privacy-setting-icon-edit").addClass("fa fa-user");
    $("#privacy-setting-name-edit").text("Only Me");
  }
});

$(document).on("click", ".remove-location", function(e) {
  var index = $(e.currentTarget).data("index");
  var isEdit = $(e.currentTarget).data("edit");

  $(".group-index-" + index).remove();

  var id = $(e.currentTarget).data("id");
  if (id != -1) {
    // If ID isn't -1, it represents an existing trip location.
    // A _destroy param must be set in order to delete de trip location from the database.
    var removeInput = $("<input></input>");
    removeInput.attr("type", "hidden");
    removeInput.attr("name", "trip[trip_locations_attributes[" + index +"][_destroy]]");
    removeInput.attr("value", true);

    $(".removed-locations").append(removeInput);
  }

  var locationsIndexString = isEdit ? $(".locations-index-edit").val() : $(".locations-index").val();;
  var locationsIndex = parseInt(locationsIndexString);
  locationsIndex--;

  if (isEdit) {
    $(".locations-index-edit").attr("value", locationsIndex);
  } else {
    $(".locations-index").attr("value", locationsIndex);
  }
});

function onAddCityClick(isEdit) {
  var locationsIndex = isEdit ? $(".locations-index-edit").val() : $(".locations-index").val();;
  var lastEndDate = $("input.trip-end-date[data-edit='" + isEdit + "'][data-index='" + locationsIndex + "']").val();
  locationsIndex++;

  if (isEdit) {
    $(".locations-index-edit").attr("value", locationsIndex);
  } else {
    $(".locations-index").attr("value", locationsIndex);
  }

  var locationGroup = $("<div></div>");
  locationGroup.addClass("group-index-" + locationsIndex);

  var locationRow = buildLocationRow(locationsIndex, isEdit);
  locationGroup.append(locationRow);

  var datesRow = buildDatesRow(locationsIndex, isEdit, lastEndDate);
  locationGroup.append(datesRow);

  var removeLocationRow = buildRemoveLocationRow(locationsIndex, isEdit);
  locationGroup.append(removeLocationRow);

  var hr = $("<hr>");
  locationGroup.append(hr);

  if (isEdit) {
    $(".cities-container-edit").append(locationGroup);
  } else {
    $(".cities-container").append(locationGroup);
  }

  setDatetimePickerStartAt(isEdit, locationsIndex);

  if (lastEndDate == '') {
    setDatetimePickerEndAt(isEdit, locationsIndex, 0);
  } else {
    var minDate = formatToMinDate(new Date(lastEndDate));
    setDatetimePickerEndAt(isEdit, locationsIndex, minDate);
  }
}

function buildLocationRow(locationsIndex, isEdit) {
  var locationRow = $("<div></div>");
  locationRow.addClass("form-group row");

  var locationLabelContainer = $("<div></div>");
  locationLabelContainer.addClass("col-sm-2");

  var locationLabel = $("<label>Location</label>");
  locationLabelContainer.append(locationLabel);

  locationRow.append(locationLabelContainer);

  var locationContainer = $("<div></div>");
  locationContainer.addClass("col-sm-10");

  var autocompleteContainer = $("<div></div>");
  autocompleteContainer.addClass("container-autocomplete");

  var locationInput = $("<input></input>");
  locationInput.addClass("form-control trip-input-text autocomplete-places");
  locationInput.attr("type", "text");
  locationInput.attr("autocomplete", "off");
  locationInput.attr("placeholder", "Enter a location");
  locationInput.attr("data-index", locationsIndex);
  locationInput.attr("data-edit", isEdit);
  autocompleteContainer.append(locationInput);

  var locationHidden = $("<input></input>");
  locationHidden.attr("type", "hidden");
  locationHidden.attr("name", "trip[trip_locations_attributes[" + locationsIndex + "][location_id]]");
  locationHidden.attr("data-edit", isEdit);
  locationHidden.attr("autocomplete", "off");
  autocompleteContainer.append(locationHidden);

  locationContainer.append(autocompleteContainer);
  locationRow.append(locationContainer);

  return locationRow;
}

function buildDatesRow(locationsIndex, isEdit, lastEndDate) {
  var datesRow = $("<div></div>");
  datesRow.addClass("form-group row");

  var startDateLabelContainer = $("<div></div>");
  startDateLabelContainer.addClass("col-sm-2");

  var startDateLabel = $("<label>Start</label>");
  startDateLabelContainer.append(startDateLabel);

  datesRow.append(startDateLabelContainer);

  var startDateContainer = $("<div></div>");
  startDateContainer.addClass("col-sm-4");

  var startDateInput = $("<input></input>");
  startDateInput.addClass("start-date-trip form-control trip-input-text");
  startDateInput.attr("type", "text");
  startDateInput.attr("autocomplete", "off");
  startDateInput.attr("data-index", locationsIndex);
  startDateInput.attr("data-edit", isEdit);

  var startDateInputHidden = $("<input></input>");
  startDateInputHidden.addClass("trip-start-date");
  startDateInputHidden.attr("type", "hidden");
  startDateInputHidden.attr("name", "trip[trip_locations_attributes[" + locationsIndex + "][start_at]]");
  startDateInputHidden.attr("data-index", locationsIndex);
  startDateInputHidden.attr("data-edit", isEdit);
  startDateInputHidden.attr("autocomplete", "off");

  if (lastEndDate != '') {
    var date = new Date(lastEndDate);
    startDateInput.val(formatToShowDate(date));
    startDateInputHidden.val(date.toDateString());
  }

  startDateContainer.append(startDateInput);
  startDateContainer.append(startDateInputHidden);
  datesRow.append(startDateContainer);

  var endDateLabelContainer = $("<div></div>");
  endDateLabelContainer.addClass("col-sm-2");

  var endDateLabel = $("<label>End</label>");
  endDateLabelContainer.append(endDateLabel);

  datesRow.append(endDateLabelContainer);

  var endDateContainer = $("<div></div>");
  endDateContainer.addClass("col-sm-4");

  var endDateInput = $("<input></input>");
  endDateInput.addClass("end-date-trip form-control trip-input-text");
  endDateInput.attr("type", "text");
  endDateInput.attr("autocomplete", "off");
  endDateInput.attr("data-index", locationsIndex);
  endDateInput.attr("data-edit", isEdit);

  var endDateInputHidden = $("<input></input>");
  endDateInputHidden.addClass("trip-end-date");
  endDateInputHidden.attr("type", "hidden");
  endDateInputHidden.attr("name", "trip[trip_locations_attributes[" + locationsIndex + "][end_at]]");
  endDateInputHidden.attr("data-index", locationsIndex);
  endDateInputHidden.attr("data-edit", isEdit);
  endDateInputHidden.attr("autocomplete", "off");

  endDateContainer.append(endDateInput);
  endDateContainer.append(endDateInputHidden);
  datesRow.append(endDateContainer);

  return datesRow;
}

function buildRemoveLocationRow(locationsIndex, isEdit) {
  var removeLocationRow = $("<div></div>");
  removeLocationRow.addClass("form-group row col-sm-12 d-flex flex-row-reverse remove-city-container");

  var removeLocationAnchor = $("<a>Remove</a>");
  removeLocationAnchor.addClass("remove-location");
  removeLocationAnchor.attr("href", "#");
  removeLocationAnchor.attr("data-index", locationsIndex);
  removeLocationAnchor.attr("data-id", -1);
  removeLocationAnchor.attr("data-edit", isEdit);

  removeLocationRow.append(removeLocationAnchor);

  return removeLocationRow;
}
