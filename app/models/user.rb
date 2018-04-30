class User < ActiveRecord::Base
  # specifies the relationship with shortend urls
  has_and_belongs_to_many :shortend_urls

  # check the uniqueness of ip for user
  # NOTE: assumption user is categorised as unique on the basis of IP
  validates :ip, uniqueness: true
end
