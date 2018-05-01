class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :city, :state, :state_code, :country, :country_code, :postal_code,
             :metro_code, :ip, :coordinates, :latitude, :longitude, :province, :province_code, :browser,
             :created_at, :updated_at
end