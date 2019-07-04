$(document).on('turbolinks:load', function() {
   function check_to_hide_or_show_add_link() {
     if ($('#new-badge .nested-fields:visible').length) {
       $('.badges').hide();
     } else {
       $('.badges').show();
     }
   }

   $('#new-badge').on('cocoon:after-insert', function() {
     check_to_hide_or_show_add_link();
   });

   $('#new-badge').on('cocoon:after-remove', function() {
     check_to_hide_or_show_add_link();
   });

   check_to_hide_or_show_add_link();
 });
