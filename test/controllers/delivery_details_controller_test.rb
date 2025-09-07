require "test_helper"

class DeliveryDetailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get delivery_details_new_url
    assert_response :success
  end

  test "should get create" do
    get delivery_details_create_url
    assert_response :success
  end

  test "should get edit" do
    get delivery_details_edit_url
    assert_response :success
  end

  test "should get update" do
    get delivery_details_update_url
    assert_response :success
  end
end
