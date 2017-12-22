$(".rooms_controller.show_action, .settings_controller.edit_action").ready(function() {
  room_code = $('#room-code').data('room-code');
  
  // Announce that we joined the room to the other users
  $.post('/publish/' + room_code + '/announce_user_joining');

  // When "Leave" button clicked, announce to others
  $('#leave').on('click', function(e) {
    e.preventDefault();

    $.post('/publish/' + room_code + '/announce_user_leaving', function(data) {
      // After announcing, actually leave the room
      // alert("finished announcing that I'm leaving");
      httpRequest('/rooms/' + room_code + '/users', {}, 'delete');
    });
  });
});
