// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery3
//= require popper
//= require bootstrap
//= require rails-ujs
//= require jquery-ui
//= require_self


$(document).ready(function () {
  $('.datepicker').datepicker({ dateFormat: 'yy-mm-dd' });

  if ($('#overview_fees_container').length > 0) {
    $.ajax({
      url : '/load_fees.js',
      retries : 0,
      retryLimit : 10,
      success : function(json) {
        console.log('reload_fees.js success after ' +  this.retries + ' retries.');
      },
      error : function(jqxhr, settings, exception) {
        this.retries++;
        var me = this;
        if (this.retries <= this.retryLimit) {
          setTimeout(function(){
            $.ajax(me);
          }, 2000);
        } else {
          var error = '<h2 class="text-muted">' + exception + '</h2>';
          var reload = '<p class="text-muted"><a href="#" onclick="window.location.reload(); return false;">Reload</a></p>';
          var html = error + reload;
          $('#overview_fees_container').empty().append(html);
        }
      }
    });
  }
});
