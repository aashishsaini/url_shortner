FactoryBot.define do
  factory :shortend_url do
    original_url Faker::Internet.url
    short_url Faker::Internet.password(6).downcase
    sanitize_url Faker::Internet.url
    page_title Faker::Company.name
    hits 0
  end
end
