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
end