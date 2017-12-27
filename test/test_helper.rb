require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
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
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  # Use the capybara javascript driver
  # def use_javascript_driver
  #   Capybara.current_driver = :selenium
  # end

  # Reset sessions and driver between tests
  # Use super wherever this method is redefined in your individual test classes
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver

    # browser = Capybara.current_session.driver.browser
    # if browser.respond_to?(:clear_cookies)
    #   # Rack::MockSession
    #   browser.clear_cookies
    # elsif browser.respond_to?(:manage) and browser.manage.respond_to?(:delete_all_cookies)
    #   # Selenium::WebDriver
    #   browser.manage.delete_all_cookies
    # else
    #   raise "Don't know how to clear cookies. Weird driver?"
    # end
  end

  # Initialize a new window
  # Source: https://kierancodes.com/blog/how-to-test-multiple-websocket-sessions-with-minitest-and-rails-5-system-tests
  def within_session(name)
    old_session_name = Capybara.session_name
    Capybara.session_name = name.to_sym

    yield

    Capybara.session_name = old_session_name
  end

  # Close a session (sessions close automatically after test suite ends)
  def close_session(name, original_session = :default)
    Capybara.session_name = name.to_sym
    page.driver.quit
    Capybara.session_name = original_session
  end

  # Runs assert_difference with a number of conditions and varying difference counts.
  #
  # Usage: assert_differences([['Model1.count', 2], ['Model2.count', 3]])
  # Source: http://wholemeal.co.nz/blog/2011/04/06/assert-difference-with-multiple-count-values/
  def assert_differences(expression_array, message = nil, &block)
    b = block.send(:binding)
    before = expression_array.map { |expr| eval(expr[0], b) }

    yield

    expression_array.each_with_index do |pair, i|
      e = pair[0]
      difference = pair[1]
      error = "#{e.inspect} didn't change by #{difference}"
      error = "#{message}\n#{error}" if message
      assert_equal(before[i] + difference, eval(e, b), error)
    end
  end

  # Refresh the page
  def refresh_page
    visit current_path
  end

  # Authenticate as a particular user
  def authenticate_as(user, room_code)
    post join_path,
         params: { room: { code: room_code },
                   user_id: user.id,
                   remember_token: 'my_token' }
  end

  # Creates a new room, and returns its room code
  def create_room(host_name = "host")
    visit root_path
    click_on 'new-room'
    fill_in 'name', with: host_name
    click_on 'submit'
    room_code = current_path.split('/')[2]
    return room_code
  end

  # Join the room as a guest user, for the first time
  def join_room(room_code, guest_name)
    visit root_path
    fill_in 'room_code', with: room_code
    click_on 'join-room'
    fill_in 'name', with: guest_name
    click_on 'submit'
  end

  # Rejoin the room
  def rejoin_room(room_code)
    visit root_path
    fill_in 'room_code', with: room_code
    click_on 'join-room'
  end

  # Assert the controller action that was used to render the page
  # def assert_controller_action(controller_name, action_name)
  #   assert page.has_css?("#container.#{controller_name}_controller.#{action_name}_action")
  # end

  # Wait for AJAX requests to finish
  # Source: https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
  # def wait_for_ajax
  #   Timeout.timeout(Capybara.default_max_wait_time) do
  #     loop while finished_all_ajax_requests? # Wait for first request,
  #     loop until finished_all_ajax_requests? # then wait until they all finish.
  #   end
  # end

  private 

    # Returns true iff there are no active AJAX requests (tracked by jQuery)
    # def finished_all_ajax_requests?
    #   page.evaluate_script('jQuery.active').zero?
    # end
end