// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function nxtClick() {
  $('.nxtFeed').click(function(){
    $(this).parents().popover('hide')
    $($(this).data('nxtid')).popover('show')
    $('.travel-feed').parents("div.popover").addClass($(this).data('nxtclass'))
    $(".finish-onboard").click(function(){
      window.location.href = "/feed"
    })
    nxtClick()
    backClick()
  })
}

function backClick() {
  $('.backFeed').click(function(){
    $(this).parents().popover('hide')
    $($(this).data('backid')).popover('show')
    $('.travel-feed').parents("div.popover").removeClass($(this).data('backclass'))
    backClick()
    nxtClick()
  })
}

$(document).ready(function () {

  $("[data-toggle=popover]").popover({
      html : true,
      content: function() {
        var content = $(this).attr("data-popover-content");
        return $(content).children(".popover-body").html();
      },
      title: function() {
        var title = $(this).attr("data-popover-content");
        return $(title).children(".popover-header").html();
      },
  });
  
  $('#onloading-popup').modal('show');
  $(".finish-onboard").click(function(){
    window.location.href = "/feed"
  });
  $('#start-tour').on('click', function () {
    $('#tour-0').popover('show');
    $('.travel-feed').parents("div.popover").addClass("popover-parent")
    nxtClick();
  })

  var navListItems = $('div.setup-panel div a'),
          allWells = $('.setup-content'),
          allNextBtn = $('.nextBtn'),
          onboardingFormUserButton = $('.onboardingFormUserButton'),
  		  allPrevBtn = $('.prevBtn');

  allWells.hide();
  $("#step-1").show();

  navListItems.click(function (e) {
      e.preventDefault();
      var $target = $($(this).attr('href')),
              $item = $(this);

      if (!$item.hasClass('disabled')) {
          navListItems.removeClass('btn-primary').addClass('btn-default');
          $item.addClass('btn-primary');
          allWells.hide();
          $target.show();
          $target.find('input:eq(0)').focus();
      }
  });
  
  allPrevBtn.click(function(){
      var curStep = $(this).closest(".setup-content"),
          curStepBtn = curStep.attr("id"),
          prevStepWizard = $('div.setup-panel div a[href="#' + curStepBtn + '"]').parent().prev().children("a");

          prevStepWizard.removeAttr('disabled').trigger('click');
  });

  allNextBtn.click(function(event){
        var curStep = $(this).closest(".setup-content")
        var cId = curStep.attr('id').split('step-')[1]
        var nxtId = parseInt(cId) + 1
        $("#step-"+cId).hide();
        $("#step-"+nxtId).show();
  });

  onboardingFormUserButton.click(function(event) {
    var isValid = validateOnboardingUserForm(event);

    if (isValid) {
      var curStep = $(this).closest(".setup-content")
      var cId = curStep.attr('id').split('step-')[1]
      var nxtId = parseInt(cId) + 1
      $("#step-"+cId).hide();
      $("#step-"+nxtId).show();
    }
  });

  $('div.setup-panel div a.btn-primary').trigger('click');
});

// Validates trip forms like creation and edition.
// Provides immediate feedback for users about inputs.
function validateOnboardingUserForm(event) {
  var isValid = true;

  var locationIdElement = $("#onboarding-user-form input[name='user[location_id]']");
  var locationInput = $("#onboarding-user-form input.autocomplete-places");
  if (locationIdElement.val() === '') {
    isValid = false;
    locationInput.addClass('validation-error');
  } else {
    locationInput.removeClass('validation-error');
  }

  if (!isValid) {
    event.preventDefault();
    event.stopPropagation();
  }

  return isValid;
}
