// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "bootstrap";
import "jquery";
import "datepicker";

// init jquery datepicker
$(document).ready(function () {
   $('.datepicker').datepicker();
});
