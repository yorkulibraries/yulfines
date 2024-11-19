// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "bootstrap";
import "jquery";
import "datepicker";

$(document).ready(function () {
   $('.datepicker').datepicker();

   if ($('#overview_fees_container').length > 0) {
      $.getScript('/alma/reload_fees.js');
   }
});
