require 'test_helper'

class SiteLayoutTestTest < ActionDispatch::IntegrationTest
  test "home page" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", help_path
    # TODO: create room, join room paths
  end
end
