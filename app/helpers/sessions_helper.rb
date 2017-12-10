module SessionsHelper
  # Remember the user in a persistent session
  def remember(user)
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Forget a persistent session
  def forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Returns the current user, according to their token, or nil
  def current_user
    user_id = cookies.signed[:user_id]
    user = User.find_by(id: user_id)
    if user && user.authenticated?(:remember, cookies[:remember_token])
      return user
    else
      forget
      return nil
    end
  end

  # Returns true if the current user has previously joined the given room
  def has_already_joined?(room, user = nil)
    user ||= current_user
    !user.nil? && user.room_id == room.id
  end

  # Returns true if the current user is the host of the given room 
  def is_host?(room, user = nil)
    user ||= current_user
    has_already_joined?(room, user) && room.host_id == user.id
  end
end