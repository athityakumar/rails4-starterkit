//= require jquery
//= require_tree
'use strict';
$(document).ready(function() {
  if ( $('#concierge_modal').length > 0 ) {
    $('#concierge_modal').parsley();
  }
  if ( $('.email-subscribe-form').length > 0 ) {
    $('.email-subscribe-form').parsley();
  }
  $.fn.show_request_access_modal = function() {
    // Set to scrollTop
    $(document).scrollTop($('#section_7').position().top);
    // Show the bootstrap modal
    $('#request_access_modal').modal('show');
  }
});