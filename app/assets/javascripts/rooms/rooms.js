$(".rooms_controller.show_action").ready(function() {
  // var current_user_id = $('meta[name=user-id]').attr('content');
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
  var should_submit_ready = $('#is_ready').val() == 'true';
  setSubmitActionsButton(!should_submit_ready);

  // When submit clicked, toggle Ready button
  $('#actions-form').on('submit', function(e) {
    e.preventDefault();

    $.ajax({
      type: 'POST',
      url: this.action,
      data: $(this).serialize(),
      success: function(response) {
        var all_ready = response["all_ready"];
        if (all_ready) {
          nextDayPhase(room_code);
        } else {
          var is_ready = response["is_ready"];
          setSubmitActionsButton(is_ready);
        }
      }      
    });
  });
});

// Toggle 'disabled' class on 'Start Game' button depending on if number of roles and users matches
function setStartGameButtonDisabledClass() {
  var num_roles = parseInt($('#roles-list').data('num-roles'));
  var num_users = $('#users-list').children().length;
  if (num_roles === num_users) {
    $('#start-game').removeClass('disabled');
  } else {
    $('#start-game').addClass('disabled');
  }
}

// Toggle whether the actions form submits is_ready as true or false
function setSubmitActionsButton(is_ready) {
  $('#is_ready').val(!is_ready);
  $('#submit-actions').val(is_ready ? "Not Ready" : "Ready");
}

function nextDayPhase(room_code) {
  // Announce to everyone that the day phase has changed, forcing everyone to page refresh
  $.post('/publish/' + room_code + '/announce_day_phase_changed');
}