require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "has or belongs to many shortend urls" do
    3.times do
      shortend_url.add_user_details(ActionController::TestRequest.new)
    end
    assert_equal guest_user.shortend_urls.count, 3
  end

  test "should not create another user with same ip address" do
    @existing_user = guest_user
    @new_user = build(:user)
    assert_equal @new_user.valid?, false
  end

  test "should create another user with different ip address" do
    @existing_user = guest_user
    @new_user = build(:user, ip: new_ip)
    assert_equal @new_user.valid?, true
    assert_difference 'User.count', 1 do
      @new_user.save
    end
  end
end
