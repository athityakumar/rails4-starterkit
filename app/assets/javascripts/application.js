//= require jquery
//= require_tree
'use strict';
$(document).ready(function() {
  if ( $('#concierge_modal').length > 0 ) {
    $('#concierge_modal').parsley();
  }
  $.fn.show_request_access_modal = function() {
    // Set to scrollTop
    $(document).scrollTop($('#section_7').position().top);
    // Show the bootstrap modal
    $('#request_access_modal').modal('show');
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
      $('#request_access_modal').modal('show');
    }
  }
});