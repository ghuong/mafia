$(".rooms_controller.show_action, .settings_controller.edit_action").ready(function() {
  room_code = $('#room-code').data('room-code');
  // Announce that we joined the room to the other users
  $.post('/publish/' + room_code + '/announce_user_joining');
});