require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Returns true if test user is authenticated
  def is_authenticated?
    # !cookies['user_id'].nil? && !cookies['remember_token'].nil?
    !session[:user_id].nil?
  end

  # Authenticate as a particular user
  def authenticate_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest

  # Authenticate as a particular user
  def authenticate_as(user, room_code)
    post join_path,
         params: { room_code: room_code,
                   user_id: user.id,
                   remember_token: 'my_token' }
  end
end