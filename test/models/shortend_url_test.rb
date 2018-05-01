require 'test_helper'
require 'mechanize'

class ShortendUrlTest < ActiveSupport::TestCase
  test "should throw and error if original_url is not present" do
    @short_url = build(:shortend_url, original_url: nil)
    assert_equal @short_url.save, false
  end

  test "should create an shortend url if orginial url is present" do
    @short_url = build(:shortend_url, original_url: nil)
    assert_equal @short_url.save, false
  end

  test "should generate an short url if orginial url is present before create" do
    @short_url = build(:shortend_url, short_url: nil)
    @short_url.generate_short_url
    assert_not_nil @short_url.short_url
  end

  test "should return the alternate short url if short url is present in the system" do
    @short_url = build(:shortend_url)
    assert_not_nil @short_url.short_url
    @new_short_url = build(:shortend_url, short_url: @short_url.short_url)
    @new_short_url.generate_short_url
    assert_not_nil @new_short_url.short_url
    assert_not_equal @new_short_url.short_url, @short_url.short_url
  end

  test "returns the collection of unused urls if present" do
    @url = create(:shortend_url)
    @url.created_at = 1.year.ago
    @url.updated_at = 1.year.ago
    @url.save
    assert_equal ShortendUrl.unused_urls.count , 1
  end

  test "returns blank array if there is no unused urls in system" do
    assert_equal ShortendUrl.unused_urls.count , 0
  end

  test "should set the page title while generating a short url of an orginial url" do
    @short_url = build(:shortend_url, short_url: nil, page_title: nil)
    @short_url.generate_short_url
    assert_not_nil @short_url.short_url
    assert_not_nil @short_url.page_title
  end

  test "should set the page title as '' if url is not a valid url while generating a short url of an orginial url" do
    @short_url = build(:shortend_url, short_url: nil, page_title: nil)
    @short_url.generate_short_url
    assert_not_nil @short_url.short_url
    assert_not_nil @short_url.page_title
    assert_equal @short_url.page_title, ''
  end

  test "should return the duplicate entity in system" do
    @url = shortend_url
    @new_url = build(:shortend_url, sanitize_url: @url.sanitize_url)
    assert_not_nil @new_url.find_duplicate
  end

  test "should return nil if duplicate entity is not found in system" do
    @url = shortend_url
    @new_url = build(:shortend_url)
    assert_nil @new_url.find_duplicate
  end

  test "validate if the url that needs to be shortend should be new url" do
    @url = shortend_url
    @new_url = build(:shortend_url)
    assert_equal @new_url.is_new_url?, true
  end

  test "should return false if the url that needs to be shortend is not new url" do
    @url = shortend_url
    @new_url = build(:shortend_url, sanitize_url: @url.sanitize_url )
    assert_equal @new_url.is_new_url?, false
  end

  test "should sanitize the url" do
    @url = build(:shortend_url, sanitize_url: nil )
    @url.sanitize
    assert_not_nil @url.sanitize_url
  end

  test "should return the sanitize url in downcase" do
    url = 'WWW.GOOGLE.COM'
    @url = build(:shortend_url, original_url: url,sanitize_url: nil )
    @url.sanitize
    assert_not_nil @url.sanitize_url
    assert_equal @url.sanitize_url, url.gsub('WWW.','http://').downcase
  end

  test "get the page title of external link" do
    url = 'http://google.com'
    @url = build(:shortend_url, original_url: url)
    @url.get_set_url_title
    assert_not_nil @url.page_title
  end

  test "sets the page title as '' if external link is haux link" do
    @url = build(:shortend_url, page_title: nil)
    @url.get_set_url_title
    assert_not_nil @url.page_title
    assert_equal @url.page_title.length, 0
  end

  test "finds the existing user and adds as a creator if new url is being shortend" do
    @existing_user = guest_user
    @url = shortend_url
    @url.add_user_details(action_request)
    assert_equal @url.creator , @existing_user
  end

  test "creates the new user and add as a creator if new url is being shortend and user is not a returning user" do
    @new_user = create(:user)
    @url = create(:shortend_url, creator_id: nil)
    @url.add_user_details(action_request(@new_user.ip), false, true)
    assert_equal @url.creator , @new_user
  end

  test "finds the user and add as a list of accessors if new url is being accessed by a returning user" do
    @url = shortend_url
    @existing_user = guest_user
    assert_equal @url.hits , 0
    @url.add_user_details(action_request)
    assert_includes @url.users , @existing_user
  end

  test "creates the new user and add as a list of accessors if new url is being accessed by a non-returning user" do
    @new_user = create(:user)
    @url = create(:shortend_url, creator_id: nil)
    assert_equal @url.hits , 0
    @url.add_user_details(action_request(@new_user.ip))
    assert_includes @url.users , @new_user
  end

  test "increase the hits count to 1 if new url is being accessed by a returning user" do
    @existing_user = guest_user
    @url = create(:shortend_url, creator_id: nil)
    assert_equal @url.hits , 0
    @url.add_user_details(action_request(@existing_user.ip), true)
    assert_includes @url.users , @existing_user
    assert_equal @url.hits , 1
  end

  test "increase the hits count to 1 if new url is being accessed by a new user" do
    @new_user = create(:user)
    @url = create(:shortend_url, creator_id: nil)
    assert_equal @url.hits , 0
    @url.add_user_details(action_request(@new_user.ip), true)
    assert_includes @url.users , @new_user
    assert_equal @url.hits , 1
  end

  test "serialize the response by validating url_info as a key node in response" do
    response = ShortendUrl.serialize_response([shortend_url])
    assert_not_nil response.first[:url_info]
  end

  test "serialize the response by validating short_url as a child object node in response" do
    response = ShortendUrl.serialize_response([shortend_url])
    assert_not_nil response.first[:url_info].short_url
  end

  test "serialize the response by validating users as a child key object in response" do
    response = ShortendUrl.serialize_response([shortend_url])
    assert_not_nil response.first[:url_info].users
  end

  test "return blank serialized array if no shortened url is found in the system" do
    response = ShortendUrl.serialize_response([])
    assert_not_nil response
  end

  test "filter records using default#shortend_url_operator, #user_operator, #global_operator if shortend_url and user params are not present in query" do
    @url = create(:shortend_url)
    @user = create(:user)
    params = {'q' => ''}
    assert_not_nil ShortendUrl.search_url(params['q'])
  end

  test "filter records using overriden#shortend_url_operator, default#user_operator, default#global_operator if shortend_url and user params are not present in query and shortend_url_operator is overriden" do
    @url = create(:shortend_url)
    @user = create(:user)
    params = {'q' => {'shortend_url_operator' => 'AND'}}
    assert_not_nil ShortendUrl.search_url(params['q'])
  end

  test "filter records using default#shortend_url_operator, overriden#user_operator, default#global_operator if shortend_url and user params are not present in query and user_operator is overriden" do
    @url = create(:shortend_url)
    @user = create(:user)
    params = {'q' => {'user_operator' => 'AND'}}
    assert_not_nil ShortendUrl.search_url(params['q'])
  end

  test "filter records using default#shortend_url_operator, default#user_operator, overriden#global_operator if shortend_url and user params are not present in query and global_operator is overriden" do
    @url = create(:shortend_url)
    @user = create(:user)
    params = {'q' => {'global_operator' => 'AND'}}
    assert_not_nil ShortendUrl.search_url(params['q'])
  end

  test "filter records using default#shortend_url_operator, #user_operator, #global_operator if shortend_url is present and user params is not present in query" do
    @url = create(:shortend_url)
    @user = create(:user)
    params = {'q' => {'shortend_url'=> {'page_title' => @url.page_title}}}
    assert_not_nil ShortendUrl.search_url(params['q'])
  end

  test "filter records using default#shortend_url_operator, #user_operator, #global_operator if shortend_url is not present and user params is present in query" do
    @url = create(:shortend_url)
    @user = create(:user)
    params = {'q' => {'user'=> {'name' => @user.name}}}
    assert_not_nil ShortendUrl.search_url(params['q'])
  end

  test "filter records using default#shortend_url_operator, #user_operator, #global_operator if shortend_url and user params are present in query" do
    @url = create(:shortend_url)
    @user = create(:user)
    params = {'q' => {'user'=> {'name' => @user.name},'shortend_url'=> {'page_title' => @url.page_title}}}
    assert_not_nil ShortendUrl.search_url(params['q'])
  end
end
