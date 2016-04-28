//= require jquery
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require_tree
'use strict';
$(document).ready(function() {
  setTimeout(function() { $('.alert').fadeOut(5000) });
  $.fn.randomString = function(length) {
    var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz".split("");
    if (!length) {
      length = Math.floor(Math.random() * chars.length);
    }
    var str = "";
    for (var i = 0; i < length; i++) {
      str += chars[Math.floor(Math.random() * chars.length)];
    }
    return str;
  }
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
  if ( $('#twitter_form').length > 0 ) {
    $('#twitter_form').parsley();
  }
  if ( $('#twitter_followers').length > 0 ) {
    var twitterTable = $('#twitter_followers').dataTable({
      sPaginationType: "simple_numbers",
      bInfo: true,
      bProcessing: true,
      bServerSide: true,
      sDom: 'rt<"bottom"p><"clear">',
      language: {
        "sInfoEmpty": 'No entries to show',
        "sEmptyTable": 'There are no followers to show.'
      },
      "lengthMenu": [[10, 20, 40, 80, -1], [10, 20, 40, 80, "All"]],
      "autoWidth": false,
      aoColumns: [
        {
          "sWidth": "225px",
          "bSortable": true,
          "bVisible": true
        },
        {
          "sWidth": "150px",
          "bSortable": true,
          "bVisible": true
        },
        {
          "sWidth": "150px",
          "bSortable": true,
          "bVisible": true
        },
        {
          "sWidth": "100px",
          "bSortable": true,
          "bVisible": true
        },
        {
          "sWidth": "50px",
          "sClass": "text-center",
          "bSortable": false,
          "bVisible": true
        },
        {
          "bVisible": false
        }
      ],
      sAjaxSource: $('#twitter_followers').data('source'),
      drawCallback: function( settings ) {
        var api = this.api();
        var info = api.page.info();
        if (info.recordsTotal <= info.length) {
          $("#twitter_datatable .dataTables_paginate").hide();
        }
        else{
          $("#twitter_datatable .dataTables_paginate").show();
        }
        // DataTable Custom Select Option
        $('#dataTablesInfo').html(
          'Showing '+(info.start+1)+' - '+info.end+ ' of ' +info.recordsTotal+' documents'
        );
      }
    });
    var twitterTableApi = twitterTable.api();
    // DataTable Custom Search
    $('#twitterFollowerSearch').keyup(function(){
      twitterTableApi.search($(this).val()).draw();
    });
    $('#twitterScreenName').on('change', function() {
      var element = $(this);
      var id = element.val();
      if (id == "") {
        twitterTableApi.ajax.url("/admin/twitter.json").load();
        $('#twitterUpdateLink').html("");
      } else {
        var name = element.find("option:selected").text();
        twitterTableApi.ajax.url("/admin/twitter/"+id+"/followers.json").load();
        $('#twitterUpdateLink').html(
          $('<a>', {href: "/admin/twitter/"+id+"/job"})
            .addClass('update-tweet-confirmation')
            .css("text-decoration", "underline")
            .attr("data-name", name)
            .text("Update '"+name+"' Followers List")
        );
      }
    });
    $.fn.changeDataTableLength = function(length) {
      twitterTableApi.page.len(length).draw();
    }
    $(document).on('click', '.update-tweet-confirmation', function () {
      var screenName = $(this).attr("data-name");
      return confirm('Are you sure want to update the twitter user "'+screenName+'"?');
    });
  }
});
