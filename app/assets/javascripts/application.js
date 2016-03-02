//= require_tree
'use strict';
$(document).ready(function() {
  $.fn.submit_contact_details = function(event, ele) {
    event = event || window.event;
    event.preventDefault();
    var element = $(ele);
    var form = element.closest('form');
    var email = form.find('input[type="email"]');
    var email_validate = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    if (email_validate.test(email.val())) {
      form.submit();
      return true;
    } else {
      email.focus();
      var email_error_ele = form.find('.contact-email-error');
      email_error_ele.css('margin-top','3px');
      email_error_ele.html('Please enter your email ID.');
      setTimeout(function() {
        email_error_ele.html('').css('margin-top','');
      }, 5000);
    }
  }
});

$(document).ready(function() {
  $('#fullpage').fullpage({
    css3: true,
    scrollingSpeed: 1000
  })
})