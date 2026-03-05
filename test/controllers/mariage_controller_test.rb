require "test_helper"

class MariageControllerTest < ActionDispatch::IntegrationTest
  test "should get wedding_design" do
    get mariage_wedding_design_url
    assert_response :success
  end
end
