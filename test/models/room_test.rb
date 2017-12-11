require 'test_helper'

class RoomTest < ActiveSupport::TestCase

  def setup
    @room = Room.new
  end

  test "should be valid" do
    assert @room.valid?
  end

  test "should be in pregame" do
    assert @room.is_pregame?
  end

  test "should be saved with code" do
    @room.save
    assert_equal 4, @room.reload.code.length
  end
end
