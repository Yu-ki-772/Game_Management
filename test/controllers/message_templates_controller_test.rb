require "test_helper"

class MessageTemplatesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get message_templates_index_url
    assert_response :success
  end
end
