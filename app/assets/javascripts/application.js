//= require jquery
//= require_tree
'use strict';
$(document).ready(function() {
  $.fn.show_request_access_modal = function() {
    // Set to scrollTop
    $(document).scrollTop($('#section_7').position().top);
    // Show the bootstrap modal
    $('#request_access_modal').modal({
      backdrop: 'static',
      keyboard: false
    });
  }
  $.fn.get_early_access = function(eve, element) {
    eve = eve || window.event;
    eve.preventDefault();
    var form = $(element).closest('form');
    var email = form.find('input[type="email"]');
    if (email.val() == "") {
      var err_ele = form.find('.email-error');
      err_ele.text('Could you fill the email address please?');
      email.on('focus', function() {
        err_ele.text('')
      });
      return false;
    } else {
      $('#concierge_email').val(email.val());
      $('#request_access_modal').modal({
        backdrop: 'static',
        keyboard: false
      });
    }
  }
  if ( $('#concierge_modal').length > 0 ) {
    $('#concierge_modal').parsley();
    $('#concierge_modal').on('submit', function(e) {
      e.preventDefault();
      var form = $(this);
      form.parsley().validate();
      if (form.parsley('isValid')) {
        $('#request_access_submit').val('Requesting...').attr('disabled', 'true');
        $.ajax({
          url: form.attr('action'),
          data: form.serialize(),
          type: 'post',
          success: function() {
            $('.clearfield').val("");
            $('#request_access_modal .modal-body-1, #request_access_modal .modal-body-2').toggle();
            $('#request_access_submit').val('REQUEST ACCESS').removeAttr('disabled');
          },
          error: function() {
            $('#request_access_submit').val('REQUEST ACCESS').removeAttr('disabled');
            alert("There was a problem with us receiving your data. Please refresh this page and try again. Or contact us at info@contractiq.com. We're sorry this happened! :(");
          }
        });
      } else {
        alert("This form isn't valid");
      }
    });
    $('#concierge_name').on('blur', function() {
      var name = $(this).val();
      $('#request_person_name').text(name);
    })
  }
});
