require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def is_authenticated?
    !cookies['user_id'].nil? && !cookies['remember_token'].nil?
  end

  def authenticate_as(user)
    cookies.signed['user_id'] = user.id
    cookies['authentication_token'] = user.authentication_token
  end
end
