FactoryBot.define do
  factory :user do
    name Faker::Internet.user_name
    address Faker::Address.street_address
    city Faker::Address.city
    state Faker::Address.state
    state_code Faker::Address.state_abbr
    country Faker::Address.country
    country_code Faker::Address.country_code
    postal_code Faker::Address.postcode
    metro_code Faker::Address.postcode
    ip Faker::Internet.ip_v4_address
    coordinates [Faker::Address.latitude, Faker::Address.longitude]
    latitude Faker::Address.latitude
    longitude Faker::Address.longitude
    province Faker::Address.state_abbr
    province_code Faker::Address.state_abbr
    browser Faker::Internet.user_agent
  end
end
