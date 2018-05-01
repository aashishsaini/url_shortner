require "test_helper"

class ShortendUrlsTest < ActionDispatch::IntegrationTest
  test "access index page" do
    get "/"
    assert_response :success
    assert_select 'h2','Enter the url'
  end

  test "access shortend url page" do
    @url = shortend_url
    get "/shortend/#{@url.short_url}"
    assert_response :success
    assert_select 'h2',"Your original URl is: #{@url.original_url}"
    assert_select 'a', "#{request.host_with_port}/#{@url.short_url}"
  end
end