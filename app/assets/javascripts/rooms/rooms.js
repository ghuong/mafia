$(".rooms_controller.show_action, .settings_controller.edit_action").ready(function() {
  room_code = $('#room-code').data('room-code');
  $.post('/publish/' + room_code + '/room_users');
  // $.post('/blah')
});