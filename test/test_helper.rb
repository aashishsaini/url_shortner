ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_bot_rails'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def shortend_url
    create(:shortend_url, creator_id: guest_user.id)
  end

  def guest_user
    @user ||= create(:user)
  end

  def new_ip
    Faker::Internet.ip_v4_address
  end
end
