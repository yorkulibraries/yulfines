// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "bootstrap";
import "jquery";
import "datepicker";

$(document).ready(function () {
  $('.datepicker').datepicker();

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
