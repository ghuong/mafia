require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    pregame_room = rooms(:pregame_room)
    @user = User.new(name: "Josh", room_id: pregame_room.id)
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "should not be host" do
    assert_not @user.is_host?
  end

  test "should be saved with digest" do
    @user.save
    assert @user.reload.authenticated?(:remember, @user.remember_token)
  end

  test "should be saved with trailing spaces in name removed" do
    @user.name = "   Rory   "
    @user.save
    assert_equal "Rory", @user.reload.name
  end

  test "should not be saved in non-existent room" do
    @user.room_id = "0000"
    assert_not @user.save
  end

  test "should not be saved with duplicated name" do
    @user.name = "  geORgE  " # name of the host
    assert_not @user.save
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
end
