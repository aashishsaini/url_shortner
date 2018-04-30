class ShortendUrl < ActiveRecord::Base
  UNIQUE_ID_LENGTH= 10
  validates :original_url, presence: true, on: :create
  validates_format_of :original_url, :with => URI::regexp(%w(http https))
  before_create :generate_short_url
  before_create :sanitize
  belongs_to :creator, :class_name => 'User'
  has_and_belongs_to_many :users

  def generate_short_url
    url = ([*('a'..'z'), *('0'..'9')]).sample(UNIQUE_ID_LENGTH).join
    old_url = ShortendUrl.where(short_url: url).last
    if old_url.present?
      self.generate_short_url
    else
      self.short_url = url
    end
  end

  def find_duplicate
    ShortendUrl.find_by_sanitize_url(self.sanitize_url)
  end

  def is_new_url?
    find_duplicate.nil?
  end

  def sanitize
    self.original_url.strip!
    self.sanitize_url = self.original_url.downcase.gsub(/(http?:\/\/)|(https?:\/\/)|(www\.)/, '')
    self.sanitize_url = "http://#{self.sanitize_url}"
  end
end
