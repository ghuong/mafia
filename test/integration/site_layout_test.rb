require 'test_helper'

class SiteLayoutTestTest < ActionDispatch::IntegrationTest

  test "home page links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", new_room_path
  end
end
