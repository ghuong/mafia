module PublishHelper
  def vote_channel(room_code, action_name, user_id)
    PRIVATE_PUB_CHANNELS[:other_votes] + "/#{room_code}/#{action_name}/#{user_id}"
  end

  def ready_channel(room_code, user_id)
    PRIVATE_PUB_CHANNELS[:ready] + "/#{room_code}/#{user_id}"
  end
end