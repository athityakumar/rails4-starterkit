//= require_tree
'use strict';
window.onload = function() {

  if (document.getElementById('email_process_btn') != null) {

    document.getElementById('email_process_btn').addEventListener('click', function(event) {

      event.preventDefault();

      var email = document.getElementById('contact_email');

      var form = document.getElementById('email_process');

      var email_validate = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;

      if (email_validate.test(email.value)) {

        form.submit();
        return true;

      } else {

        email.focus();
        var email_error_ele = document.getElementById('contact_email_error');
        email_error_ele.setAttribute('style', 'display: block; position: absolute; font-size: 12px; color: red; margin-top: 3px;');
        email_error_ele.innerHTML = 'Please enter your official email ID.';

        setTimeout(function() {
          email_error_ele.style.display = 'none';
        }, 5000);

      }
    });
    
  }

}

$(document).ready(function() {
  $('#fullpage').fullpage({
    css3: true,
    scrollingSpeed: 1000
  })
})