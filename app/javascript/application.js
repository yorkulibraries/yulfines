// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "bootstrap";
import "jquery";
import "datepicker";

$(document).ready(function () {
   $('.datepicker').datepicker();

   if ($('#overview_fees_container').length > 0) {
      $.getScript('/alma/reload_fees.js').fail(function( jqxhr, settings, exception ) {
         var error = '<h2 class="text-muted">' + exception + '</h2>';
         var reload = '<p class="text-muted"><a href="#" onclick="window.location.reload(); return false;">Reload</a></p>';
         var html = error + reload;
         $('#overview_fees_container').empty().append(html);
      });
   }
});
