$(".rooms_controller.show_action").ready(function() {
  var room_code = $('#room-code').data('room-code');
  
  // Announce that we joined the room to the other users
  $.post('/publish/' + room_code + '/announce_user_joining');

  // When "Leave" button clicked, announce to others
  $('#leave').on('click', function(e) {
    e.preventDefault();

    $.post('/publish/' + room_code + '/announce_user_leaving', function(data) {
      // After announcing, actually leave the room
      httpRequest('/rooms/' + room_code + '/users', {}, 'delete');
    });
  });
});

$('.settings_controller.edit_action').ready(function() {
  var room_code = $('#room-code').data('room-code');

  // Update all guest user's role counts
  $.post('/publish/' + room_code + '/announce_roles_updated');

  // Enable 'Start Game' button if number of roles matches number of users
  setStartGameButtonDisabledClass();

  $('#users-list').on('append', function() {
    setStartGameButtonDisabledClass();
  });
});

$('.actions_controller.edit_action').ready(function() {
  var room_code = $('#room-code').data('room-code');

  // Announce to all guests that game has started
  $.post('/publish/' + room_code + '/announce_game_started');

  // Convert Ready button to 'Not Ready' if user is ready
  var is_ready = $('#is_ready').val();
  setSubmitActionsButton(is_ready);

  // When submit clicked, toggle Ready button
  $('#actions-form').on('submit', function(e) {
    e.preventDefault();

    $.ajax({
      type: 'POST',
      url: this.action,
      data: $(this).serialize(),
      success: function(response) {
        var is_ready = response["is_ready"];
        setSubmitActionsButton(is_ready);
      }      
    });
  });
});

function setStartGameButtonDisabledClass() {
  var num_roles = parseInt($('#roles-list').data('num-roles'));
  var num_users = $('#users-list').children().length;
  if (num_roles === num_users) {
    $('#start-game').removeClass('disabled');
  } else {
    $('#start-game').addClass('disabled');
  }
}

function setSubmitActionsButton(is_ready) {
  $('#is_ready').val(!is_ready);
  $('#submit-actions').val(is_ready ? "Not Ready" : "Ready");
}