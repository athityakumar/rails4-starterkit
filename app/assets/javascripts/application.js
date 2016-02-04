// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap_alert
//= require bootstrap_button

$(document).ready(function() {
  'use strict';
  // Some Addition custom jquery function  
  jQuery.fn.extend({
    toggleText: function() {
      var altText = this.data('alt-text'); // add data-toggle="toggleText", and set data-alt-text="xxxx"
      if (altText) {
        this.data('alt-text', this.html());
        this.html(altText);
      }
    }
  });
  // Remove alert message
  setTimeout(function() {
    $('.alert').remove();
  }, 10000);
  // To check whether the input is not null/ empty

  if($('#email_process').length > 0) {
    $('#email_process input[type="submit"]').on('click', function(e) {
      e = e || window.event;
      e.preventDefault();
      var email = $('#contact_email').val();
      var email_validate = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
      if (email_validate.test(email)) {
        $('#email_process').submit();
        return true;
      } else {
        $('#contact_email').focus();
        $('#contact_email_error').text('Please enter your official email ID.').css({'margin-top':'5px', 'color':'red', 'font-size':'12px'}).show();
        setTimeout(function() {
          $('#contact_email_error').hide()
        }, 5000);
      }
      return false;
    });
  }
});